# https://www.terraform.io/docs/language/meta-arguments/lifecycle.html#ignore_changes
#   We ignore changes to tags since they can take new values on each run (terraform plan/apply).
#   These updates are based on semantic rules managed outside of the Terraform scope.

# ====================================================================================================
#  CLUSTER
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster
# https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html
# https://docs.aws.amazon.com/eks/latest/userguide/clusters.html
# https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
resource "aws_eks_cluster" "cluster" {
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceController,
    aws_security_group_rule.cluster_egress_all_internet,
    aws_cloudwatch_log_group.cluster,
  ]

  name                      = var.name
  role_arn                  = aws_iam_role.cluster.arn
  version                   = var.cluster_version
  enabled_cluster_log_types = var.enable_cluster_logs ? [ "api", "audit", "authenticator" ] : []

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster#vpc_config-arguments
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [ aws_security_group.cluster.id ]

    endpoint_private_access = false # Amazon EKS private API server endpoint is disabled
    endpoint_public_access  = true  # Amazon EKS public API server endpoint is enabled.
    public_access_cidrs     = var.public_api_cidrs
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_service_ipv4_cidr
  }

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster#timeouts
  timeouts {
    create = var.timeouts.create
    update = var.timeouts.update
    delete = var.timeouts.delete
  }

  tags = merge(var.common_tags, var.cluster_tags, {
    Name = var.name
  })

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "cluster" {
  count = var.enable_cluster_logs ? 1 : 0

  name              = "/aws/eks/${var.name}/cluster"
  retention_in_days = var.logs_retention_days

  tags = merge(var.common_tags, {
    Name = format("%s-cluster", var.name)
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

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "cluster" {
  name = "${var.name}-cluster"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })

  tags = merge(var.common_tags, {
    Name = format("%s-cluster", var.name)
  })

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSVPCResourceController" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# ====================================================================================================
#  SECURITY GROUP
# ====================================================================================================

# Additional security group for the cluster to communicate with self-managed nodes and the Internet.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
# https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
resource "aws_security_group" "cluster" {
  name   = "${var.name}-cluster"
  vpc_id = var.vpc_id

  tags = merge(var.common_tags, {
    Name = format("%s-cluster", var.name)
  })

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "cluster_egress_all_internet" {
  type              = "egress"
  protocol          = "all"
  from_port         = 0
  to_port           = 0
  security_group_id = aws_security_group.cluster.id
  cidr_blocks       = var.cluster_egress_cidrs
  description       = "Allow cluster outbound access to the Internet."
}
