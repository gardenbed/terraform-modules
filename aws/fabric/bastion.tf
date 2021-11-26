# https://www.terraform.io/docs/language/meta-arguments/lifecycle.html#create_before_destroy
# https://www.terraform.io/docs/language/meta-arguments/lifecycle.html#ignore_changes
#   We ignore changes to tags since they can take new values on each run (terraform plan/apply).
#   These updates are based on semantic rules managed outside of the Terraform scope.

# ====================================================================================================
#  Key
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
resource "aws_key_pair" "bastion" {
  count = var.enable_bastion ? 1 : 0

  key_name   = "${var.name}-bastion"
  public_key = file(var.bastion_public_key)

  tags = merge(var.common_tags, {
    "Name" = var.name
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
resource "aws_iam_instance_profile" "bastion" {
  count = var.enable_bastion ? 1 : 0

  name = "${var.name}-bastion"
  role = aws_iam_role.bastion.0.name

  tags = merge(var.common_tags, {
    "Name" = var.name
  })

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "bastion" {
  count = var.enable_bastion ? 1 : 0

  name = "${var.name}-bastion"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = merge(var.common_tags, {
    "Name" = format("%s-bastion", var.name)
  })

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy
resource "aws_iam_role_policy" "bastion" {
  count = var.enable_bastion ? 1 : 0

  name = "${var.name}-bastion"
  role = aws_iam_role.bastion.0.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Resource = "*"
      Action: [
        "ec2:Describe*"
      ]
    }]
  })
}

# ====================================================================================================
#  Security Group
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "bastion" {
  count = var.enable_bastion ? 1 : 0

  name   = "${var.name}-bastion"
  vpc_id = aws_vpc.main.id

  # Incoming: ICMP inside the VPC
  ingress {
    to_port     = -1
    from_port   = -1
    protocol    = "icmp"
    cidr_blocks = [ aws_vpc.main.cidr_block ]
  }

  # Incoming: All protocols inside the VPC
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ aws_vpc.main.cidr_block ]
  }

  # Incoming: SSH from trusted sources
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.bastion_cidr_whitelist
  }

  # Outgoing: All protocols to the Internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  # Outgoing: All protocols inside the VPC
  /* egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ aws_vpc.main.cidr_block ]
  } */

  tags = merge(var.common_tags, {
    "Name" = format("%s-bastion", var.name)
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      tags,
    ]
  }
}

# ====================================================================================================
#  Launch Template
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
# https://wiki.debian.org/Cloud/AmazonEC2Image
# https://wiki.debian.org/Cloud/AmazonEC2Image/Stretch
data "aws_ami" "debian" {
  most_recent = true
  owners      = [ "379101102735" ]

  filter {
    name   = "name"
    values = [ "debian-stretch-hvm-x86_64-gp2-*" ]
  }

  filter {
    name   = "virtualization-type"
    values = [ "hvm" ]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
resource "aws_launch_template" "bastion" {
  count = var.enable_bastion ? 1 : 0

  name                                 = "${var.name}-bastion"
  image_id                             = data.aws_ami.debian.id
  instance_type                        = "t2.micro"
  key_name                             = aws_key_pair.bastion.0.key_name
  instance_initiated_shutdown_behavior = "terminate"

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template#instance-profile
  iam_instance_profile {
    name = aws_iam_instance_profile.bastion.0.name
  }

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template#network-interfaces
  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    security_groups             = [ aws_security_group.bastion.0.id ]
  }

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template#tag-specifications
  tag_specifications {
    resource_type = "instance"

    tags = merge(var.common_tags, {
      "Name"   = format("%s-bastion", var.name)
      "Region" = var.region
    })
  }

  tags = merge(var.common_tags, {
    "Name" = format("%s-bastion", var.name)
  })

  lifecycle {
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
resource "aws_autoscaling_group" "bastion" {
  count = var.enable_bastion ? 1 : 0

  name                 = "${var.name}-bastion"
  min_size             = 1
  desired_capacity     = 1
  max_size             = 1
  vpc_zone_identifier  = slice(aws_subnet.public.*.id, 0, local.az_len)

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#launch_template
  launch_template {
    id      = aws_launch_template.bastion.0.id
    version = aws_launch_template.bastion.0.latest_version
  }

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#tag-and-tags
  tags = [
    for k, v in merge(var.common_tags, { Name = "${var.name}-bastion" }): {
      key                 = k
      value               = v
      propagate_at_launch = true
    }
  ]

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      tags,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instance
data "aws_instance" "bastion" {
  count = var.enable_bastion ? 1 : 0

  depends_on = [ aws_autoscaling_group.bastion ]

  filter {
    name   = "tag:Name"
    values = [ "${var.name}-bastion" ]
  }
}
