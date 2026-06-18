# 1. Obtener las Zonas de Disponibilidad (AZs) de la región actual
data "aws_availability_zones" "available" {
  state = "available"
}

# 2. Creación de la VPC (Red principal)
# Databricks requiere que la resolución DNS esté activada
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.tags, {
    Name = var.vpc_name
  })
}

# 3. Internet Gateway (Para que la VPC tenga salida a internet)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, {
    Name = "${var.vpc_name}-igw"
  })
}

# 4. Subred Pública (Solo para alojar el NAT Gateway)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.cidr_block, 4, 0) # Ejemplo: 10.0.0.0/20
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = merge(var.tags, {
    Name = "${var.vpc_name}-public-subnet-1"
  })
}

# 5. IP Elástica y NAT Gateway (Permite a las subredes privadas salir a internet)
# OJO: Solo creamos UNO para ahorrar costos. En prod serían varios.
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = merge(var.tags, {
    Name = "${var.vpc_name}-nat-eip"
  })
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  depends_on    = [aws_internet_gateway.igw] # El IGW debe existir primero
  tags = merge(var.tags, {
    Name = "${var.vpc_name}-nat-gateway"
  })
}

# 6. Subredes Privadas (Donde vivirán los clústeres de Databricks)
# Databricks exige al menos 2 subredes en diferentes zonas de disponibilidad
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 4, count.index + 1) # 10.0.16.0/20 y 10.0.32.0/20
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(var.tags, {
    Name = "${var.vpc_name}-private-subnet-${count.index + 1}"
  })
}

# 7. Tablas de Ruteo
# Ruta Pública: Todo lo que va a internet (0.0.0.0/0) sale por el Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.tags, {
    Name = "${var.vpc_name}-public-rt"
  })
}

# Ruta Privada: Todo lo que va a internet sale por el NAT Gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = merge(var.tags, {
    Name = "${var.vpc_name}-private-rt"
  })
}

# 8. Asociaciones de Tablas de Ruteo a Subredes
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# 9. Security Group base para Databricks
# Regla estándar: Permite todo el tráfico de salida y comunicación interna entre los nodos
resource "aws_security_group" "databricks_sg" {
  name        = "${var.vpc_name}-databricks-sg"
  description = "Security group for Databricks workspace"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Permitir trafico interno entre nodos del cluster"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    description = "Permitir salida a internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-databricks-sg"
  })
}