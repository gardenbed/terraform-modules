# https://www.terraform.io/docs/language/meta-arguments/lifecycle.html#ignore_changes
#   We ignore changes to tags since they can take new values on each run (terraform plan/apply).
#   These updates are based on semantic rules managed outside of the Terraform scope.

# ====================================================================================================
#  Cluster
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

# ====================================================================================================
#  Keys
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
resource "aws_key_pair" "nodes" {
  key_name   = "${var.name}-nodes"
  public_key = file(var.ssh.public_key)

  tags = merge(var.common_tags, {
    Name = format("%s-nodes", var.name)
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
resource "aws_iam_instance_profile" "nodes" {
  name = "${var.name}-nodes"
  role = aws_iam_role.nodes.name

  tags = merge(var.common_tags, {
    Name = format("%s-nodes", var.name)
  })

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "nodes" {
  name = "${var.name}-nodes"

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
    Name = format("%s-nodes", var.name)
  })

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "nodes_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "nodes_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "nodes_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# ====================================================================================================
#  Security Group
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
# https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
resource "aws_security_group" "nodes" {
  name   = "${var.name}-nodes"
  vpc_id = var.vpc_id

  tags = merge(var.common_tags, {
    Name = format("%s-nodes", var.name)

    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      tags,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "nodes_ingress_all_self" {
  type                     = "ingress"
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 0
  security_group_id        = aws_security_group.nodes.id
  source_security_group_id = aws_security_group.nodes.id
  description              = "Allowing nodes to communicate with each other."
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "nodes_ingress_ssh_bastion" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  security_group_id        = aws_security_group.nodes.id
  source_security_group_id = var.bastion.security_group_id
  description              = "Allowing SSH access from bastion hosts."
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "nodes_ingress_https_cluster" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  security_group_id        = aws_security_group.nodes.id
  source_security_group_id = data.aws_eks_cluster.cluster.vpc_config.0.cluster_security_group_id
  description              = "Allowing pods running extension API servers to receive communication from the cluster."
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "nodes_ingress_all_cluster" {
  type                     = "ingress"
  protocol                 = "all"
  from_port                = 0
  to_port                  = 65535
  security_group_id        = aws_security_group.nodes.id
  source_security_group_id = data.aws_eks_cluster.cluster.vpc_config.0.cluster_security_group_id
  description              =  "Allowing nodes and pods to receive communication from the cluster."
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
resource "aws_security_group_rule" "nodes_egress_all_internet" {
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  security_group_id = aws_security_group.nodes.id
  cidr_blocks       = var.cluster_egress_cidrs
  description       = "Allowing nodes outbound access to the Internet."
}

# ====================================================================================================
#  Launch Template
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
data "aws_ami" "nodes" {
  most_recent = true
  owners      = [ "602401143452" ]  # Amazon EKS AMI Account ID

  filter {
    name   = "name"
    values = [ "amazon-eks-node-${data.aws_eks_cluster.cluster.version}-v*" ]
  }
}

# https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file
data "template_file" "node_init" {
  template = file("${path.module}/node-init.tpl")
  vars = {
    cluster_name          = var.cluster_name
    cluster_endpoint      = data.aws_eks_cluster.cluster.endpoint
    certificate_authority = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-launch-templates.html
resource "aws_launch_template" "nodes" {
  name          = "${var.name}-nodes"
  image_id      = data.aws_ami.nodes.id
  instance_type = var.profile.instance_type
  key_name      = aws_key_pair.nodes.key_name
  user_data     = base64encode(data.template_file.node_init.rendered)

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template#monitoring
  monitoring {
    enabled = true
  }

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template#instance-profile
  iam_instance_profile {
    name = aws_iam_instance_profile.nodes.name
  }

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template#network-interfaces
  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    security_groups             = [ aws_security_group.nodes.id ]
  }

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template#block-devices
  # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/block-device-mapping-concepts.html
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_type           = "gp2"
      volume_size           = var.profile.volume_size_gb
      delete_on_termination = true
    }
  }

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template#tag-specifications
  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = format("%s-node", var.name)

      "kubernetes.io/cluster/${var.cluster_name}"     = "owned"
      "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
      "k8s.io/cluster-autoscaler/enabled"             = "true"
    })
  }

  tags = merge(var.common_tags, {
    Name = format("%s-nodes", var.name)
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      tags,
      tag_specifications.0.tags,
    ]
  }
}

# ====================================================================================================
#  Auto Scaling Group
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
# https://docs.aws.amazon.com/autoscaling/ec2/userguide/create-asg-launch-template.html
resource "aws_autoscaling_group" "nodes" {
  name                 = "${var.name}-nodes"
  min_size             = var.profile.min_size
  desired_capacity     = var.profile.desired_capacity
  max_size             = var.profile.max_size
  force_delete         = false
  vpc_zone_identifier  = [ for subnet in var.subnets: subnet.id ]

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#launch_template
  launch_template {
    id      = aws_launch_template.nodes.id
    version = aws_launch_template.nodes.latest_version
  }

  # https://www.terraform.io/docs/language/expressions/dynamic-blocks.html
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#tag-and-tags
  dynamic "tag" {
    for_each = merge(var.common_tags, {
      Name = "${var.name}-node"
    })

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      tags,
    ]
  }
}
