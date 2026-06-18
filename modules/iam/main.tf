# 1. Política de Confianza (Trust Policy)
# Le decimos a AWS: "Confía en la cuenta principal de Databricks, pero SOLO si presentan mi ID de cuenta de Databricks"
data "aws_iam_policy_document" "cross_account_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      # Este es el ID oficial de la cuenta de Databricks en AWS (aplica para us-east-2 y casi todo US)
      identifiers = ["arn:aws:iam::414360345950:root"] 
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.databricks_account_id]
    }
  }
}

# 2. Creación del Rol
resource "aws_iam_role" "cross_account_role" {
  name               = "${var.prefix}-cross-account-role"
  assume_role_policy = data.aws_iam_policy_document.cross_account_trust.json
  tags               = var.tags
}

# 3. Política de Permisos (Qué puede hacer Databricks en tu cuenta)
# Permitimos gestión de EC2 (nodos Spark) y VPC (redes)
data "aws_iam_policy_document" "databricks_policy" {
  statement {
    sid = "Ec2Management"
    actions = [
      "ec2:RunInstances",
      "ec2:CreateTags",
      "ec2:DescribeInstances",
      "ec2:TerminateInstances",
      "ec2:DescribeRouteTables",
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups"
    ]
    resources = ["*"]
  }
  
  # Databricks necesita poder pasarse roles a sí mismo para las instancias EC2
  statement {
    sid = "PassRole"
    actions = ["iam:PassRole"]
    resources = ["arn:aws:iam::*:role/${var.prefix}-*"]
  }
}

# 4. Adjuntar la política al rol
resource "aws_iam_role_policy" "databricks_policy_attachment" {
  name   = "${var.prefix}-databricks-policy"
  role   = aws_iam_role.cross_account_role.name
  policy = data.aws_iam_policy_document.databricks_policy.json
}