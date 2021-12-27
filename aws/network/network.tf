# https://www.terraform.io/docs/language/meta-arguments/lifecycle.html#create_before_destroy
# https://www.terraform.io/docs/language/meta-arguments/lifecycle.html#ignore_changes
#   We ignore changes to tags since they can take new values on each run (terraform plan/apply).
#   These updates are based on semantic rules managed outside of the Terraform scope.

# ====================================================================================================
#  VPC
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "main" {
  cidr_block           = lookup(var.vpc_cidrs, var.region)
  enable_dns_support   = true
  enable_dns_hostnames = false

  tags = merge(var.common_tags, var.vpc_tags, {
    Name   = var.name
    Region = var.region
  })

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# ====================================================================================================
#  SUBNETS
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "public" {
  count = var.enable_public_subnets ? local.az_len : 0

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, 1 + count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.common_tags, var.public_subnet_tags, {
    Name   = format("%s-public-%d", var.name, count.index + 1)
    Region = var.region
  })

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "private" {
  count = var.enable_private_subnets ? local.az_len : 0

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, 128 + count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.common_tags, var.private_subnet_tags, {
    Name   = format("%s-private-%d", var.name, count.index + 1)
    Region = var.region
  })

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# ====================================================================================================
#  GATEWAYS
# ====================================================================================================

# https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "main" {
  count = var.enable_public_subnets ? 1 : 0

  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    Name   = var.name
    Region = var.region
  })

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway
resource "aws_nat_gateway" "main" {
  count = var.enable_private_subnets ? local.az_len : 0

  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  tags = merge(var.common_tags, {
    Name   = format("%s-%d", var.name, count.index + 1)
    Region = var.region
  })

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
resource "aws_eip" "nat" {
  count = var.enable_private_subnets ? local.az_len : 0

  vpc = true

  tags = merge(var.common_tags, {
    Name   = format("%s-nat-%d", var.name, count.index + 1)
    Region = var.region
  })

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# ====================================================================================================
#  ROUTE TABLES
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association

resource "aws_route_table" "public" {
  count = var.enable_public_subnets ? 1 : 0

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.0.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.main.0.id
  }

  tags = merge(var.common_tags, {
    Name   = format("%s-public", var.name)
    Region = var.region
  })

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "aws_route_table_association" "public" {
  count = var.enable_public_subnets ? local.az_len : 0

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.0.id
}

resource "aws_route_table" "private" {
  count = var.enable_private_subnets ? local.az_len : 0

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.main.*.id, count.index)
  }

  tags = merge(var.common_tags, {
    Name   = format("%s-private-%d", var.name, count.index + 1)
    Region = var.region
  })

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "aws_route_table_association" "private" {
  count = var.enable_private_subnets ? local.az_len : 0

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

# ====================================================================================================
#  SECURITY GROUP
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "main" {
  name   = "${var.name}"
  vpc_id = aws_vpc.main.id

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group#ingress

  ingress {
    protocol    = "icmp"
    to_port     = -1
    from_port   = -1
    cidr_blocks = [ aws_vpc.main.cidr_block ]
    description = "Allow ICMP traffic inside the VPC."
  }

  ingress {
    protocol    = "all"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [ aws_vpc.main.cidr_block ]
    description = "Allow all incoming traffic inside the VPC."
  }

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group#egress

  egress {
    protocol    = "all"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [ aws_vpc.main.cidr_block ]
    description = "Allow all outgoing traffic inside the VPC."
  }

  egress {
    protocol    = "all"
    from_port   = 0
    to_port     = 0
    cidr_blocks = var.outgoing_cidrs
    description = "Allow all outgoing traffic."
  }

  tags = merge(var.common_tags, {
    Name = var.name
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      tags,
    ]
  }
}
