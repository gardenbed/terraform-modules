# https://www.terraform.io/docs/language/meta-arguments/lifecycle.html#ignore_changes
#   We ignore changes to tags since they can take new values on each run (terraform plan/apply).
#   These updates are based on semantic rules managed outside of the Terraform scope.

# ====================================================================================================
#  CLOUDWATCH
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log
resource "aws_flow_log" "vpc" {
  count = var.enable_vpc_logs ? 1 : 0

  iam_role_arn         = aws_iam_role.vpc.0.arn
  log_destination      = aws_cloudwatch_log_group.vpc.0.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id

  tags = merge(var.common_tags, {
    Name = format("%s-vpc", var.name)
  })

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "vpc" {
  count = var.enable_vpc_logs ? 1 : 0

  name              = "${var.name}-vpc"
  retention_in_days = 60

  tags = merge(var.common_tags, {
    Name = format("%s-vpc", var.name)
  })

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# ====================================================================================================
#  IAM
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile
resource "aws_iam_instance_profile" "vpc" {
  count = var.enable_vpc_logs ? 1 : 0

  name = "${var.name}-vpc"
  role = aws_iam_role.vpc.0.name

  tags = merge(var.common_tags, {
    Name = var.name
  })

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "vpc" {
  count = var.enable_vpc_logs ? 1 : 0

  name = "${var.name}-vpc"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid = ""
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
    }]
  })

  tags = merge(var.common_tags, {
    Name = format("%s-vpc", var.name)
  })

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy
resource "aws_iam_role_policy" "vpc" {
  count = var.enable_vpc_logs ? 1 : 0

  name = "${var.name}-vpc"
  role = aws_iam_role.vpc.0.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Resource = aws_cloudwatch_log_group.vpc.0.arn
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
      ]
    }]
  })
}
