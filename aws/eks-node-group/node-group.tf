# https://www.terraform.io/docs/language/meta-arguments/lifecycle.html#ignore_changes
#   We ignore changes to tags since they can take new values on each run (terraform plan/apply).
#   These updates are based on semantic rules managed outside of the Terraform scope.

# ====================================================================================================
#  NODE GROUPS
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group
# https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html
# https://docs.aws.amazon.com/eks/latest/APIReference/API_Nodegroup.html
resource "aws_eks_node_group" "node_group" {
  depends_on = [
    aws_iam_role_policy_attachment.node_group_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_group_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_group_AmazonEC2ContainerRegistryReadOnly,
  ]

  node_group_name = var.name
  cluster_name    = var.cluster_name
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = var.subnets.*.id

  force_update_version = false
  capacity_type        = var.profile.capacity_type
  instance_types       = var.profile.instance_types
  disk_size            = var.profile.disk_size_gb

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group#scaling_config-configuration-block
  scaling_config {
    min_size     = var.profile.min_node_size
    desired_size = var.profile.desired_node_size
    max_size     = var.profile.max_node_size
  }

  # https://www.terraform.io/docs/language/functions/try.html
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group#update_config-configuration-block
  update_config {
    max_unavailable            = try(var.profile.max_unavailable, null)
    max_unavailable_percentage = try(var.profile.max_unavailable_percentage, null)
  }

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group#remote_access-configuration-block
  remote_access {
    ec2_ssh_key               = aws_key_pair.node_group.key_name
    source_security_group_ids = [ var.bastion.security_group_id ]
  }

  labels = merge(var.labels, {})

  # https://www.terraform.io/docs/language/expressions/dynamic-blocks.html
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group#taint-configuration-block
  dynamic "taint" {
    for_each = var.taints
    content {
      key    = taint.key
      value  = taint.value
      effect = taint.effect
    }
  }

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group#timeouts
  timeouts {
    create = var.profile.create_timeout
    update = var.profile.update_timeout
    delete = var.profile.delete_timeout
  }

  tags = merge(var.common_tags, {
    Name = format("%s-node-group", var.name)
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      tags,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
resource "aws_key_pair" "node_group" {
  key_name   = "${var.name}-node-group"
  public_key = file(var.ssh.public_key_file)

  tags = merge(var.common_tags, {
    Name = format("%s-node-group", var.name)
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
resource "aws_iam_role" "node_group" {
  name = "${var.name}-node-group"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = merge(var.common_tags, {
    Name = format("%s-node-group", var.name)
  })

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "node_group_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "node_group_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "node_group_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
