# https://www.terraform.io/docs/language/meta-arguments/lifecycle.html#create_before_destroy
# https://www.terraform.io/docs/language/meta-arguments/lifecycle.html#ignore_changes
#   We ignore changes to tags since they can take new values on each run (terraform plan/apply).
#   These updates are based on semantic rules managed outside of the Terraform scope.

# ====================================================================================================
#  LOAD BALANCER
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
# https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-listeners.html
resource "aws_lb_listener" "bastion" {
  load_balancer_arn = aws_lb.bastion.arn
  protocol          = "TCP"
  port              = 22

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener#default_action
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bastion.arn
  }

  tags = merge(var.common_tags, {
    Name = format("%s-bastion", var.name)
  })

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html
# https://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_CreateTargetGroup.html
resource "aws_lb_target_group" "bastion" {
  name        = "${var.name}-bastion"
  vpc_id      = var.vpc.id
  target_type = "instance"
  protocol    = "TCP"
  port        = 22

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#health_check
  health_check {
    enabled             = true
    protocol            = "TCP"
    port                = 22
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = merge(var.common_tags, {
    Name = format("%s-bastion", var.name)
  })

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
# https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html
resource "aws_lb" "bastion" {
  name                             = "${var.name}-bastion"
  internal                         = false
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb#access_logs
  access_logs {
    enabled = true
    bucket  = aws_s3_bucket.bastion.id
    prefix  = local.bucket_prefix
  }

  # https://www.terraform.io/docs/language/expressions/dynamic-blocks.html
  dynamic "subnet_mapping" {
    for_each = var.public_subnets.*.id
    content {
      subnet_id     = subnet_mapping.value
      allocation_id = aws_eip.bastion[subnet_mapping.key].id
    }
  }

  tags = merge(var.common_tags, {
    Name = format("%s-bastion", var.name)
  })

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html
# https://docs.aws.amazon.com/elasticloadbalancing/latest/network/network-load-balancers.html#availability-zones
resource "aws_eip" "bastion" {
  count = length(var.public_subnets)

  vpc = true

  tags = merge(var.common_tags, {
    Name = format("%s-bastion", var.name)
  })

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# ====================================================================================================
#  AUTO SCALING GROUP
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
resource "aws_autoscaling_group" "bastion" {
  name                 = "${var.name}-bastion"
  min_size             = 1
  desired_capacity     = 1
  max_size             = 1
  vpc_zone_identifier  = var.public_subnets.*.id
  target_group_arns    = [ aws_lb_target_group.bastion.arn ]

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#launch_template
  launch_template {
    id      = aws_launch_template.bastion.id
    version = aws_launch_template.bastion.latest_version
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

# ====================================================================================================
#  LAUNCH TEMPLATE
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
resource "aws_launch_template" "bastion" {
  name                                 = "${var.name}-bastion"
  image_id                             = data.aws_ami.debian.id
  instance_type                        = var.instance_type
  key_name                             = aws_key_pair.bastion.key_name
  instance_initiated_shutdown_behavior = "terminate"

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template#instance-profile
  iam_instance_profile {
    name = aws_iam_instance_profile.bastion.name
  }

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template#network-interfaces
  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = [ aws_security_group.bastion.id ]
  }

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template#tag-specifications
  tag_specifications {
    resource_type = "instance"

    tags = merge(var.common_tags, {
      Name = format("%s-bastion", var.name)
    })
  }

  tags = merge(var.common_tags, {
    Name = format("%s-bastion", var.name)
  })

  lifecycle {
    ignore_changes = [
      tags,
      tag_specifications.0.tags,
    ]
  }
}

# https://wiki.debian.org/Cloud/AmazonEC2Image
# https://wiki.debian.org/Cloud/AmazonEC2Image/Stretch
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
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

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
resource "aws_key_pair" "bastion" {
  key_name   = "${var.name}-bastion"
  public_key = file(var.ssh_public_key_file)

  tags = merge(var.common_tags, {
    Name = var.name
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
  name = "${var.name}-bastion"
  role = aws_iam_role.bastion.name

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
resource "aws_iam_role" "bastion" {
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
    Name = format("%s-bastion", var.name)
  })

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy
resource "aws_iam_role_policy" "bastion" {
  name = "${var.name}-bastion"
  role = aws_iam_role.bastion.id

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
#  SECURITY GROUP
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "bastion" {
  name   = "${var.name}-bastion"
  vpc_id = var.vpc.id

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group#ingress

  ingress {
    protocol    = "icmp"
    to_port     = -1
    from_port   = -1
    cidr_blocks = [ var.vpc.cidr ]
    description = "Allow ICMP traffic inside the VPC."
  }

  ingress {
    protocol    = "all"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [ var.vpc.cidr ]
    description = "Allow all incoming traffic inside the VPC."
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = var.ssh_cidrs
    description = "Allow ssh access from trusted sources."
  }

  # load balancer healtcheck
  ingress {
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22
    cidr_blocks     = var.public_subnets.*.cidr
    description     = "Allow load balancer access for healthchecks."
  }

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group#egress

  egress {
    protocol    = "all"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [ var.vpc.cidr ]
    description = "Allow all outgoing traffic inside the VPC."
  }

  egress {
    protocol    = "all"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Allow all outgoing traffic to the Internet."
  }

  tags = merge(var.common_tags, {
    Name = format("%s-bastion", var.name)
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      tags,
    ]
  }
}
