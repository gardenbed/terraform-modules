# https://www.terraform.io/docs/language/meta-arguments/lifecycle.html#ignore_changes
#   We ignore changes to tags since they can take new values on each run (terraform plan/apply).
#   These updates are based on semantic rules managed outside of the Terraform scope.

# ====================================================================================================
#  S3
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id
resource "random_id" "bastion_bucket" {
  byte_length = 8
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "bastion" {
  bucket        = "${var.name}-bastion-${random_id.bastion_bucket.hex}"
  force_destroy = true

  tags = merge(var.common_tags, {
    Name = format("%s-bastion", var.name)
  })

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl
resource "aws_s3_bucket_acl" "bastion" {
  bucket = aws_s3_bucket.bastion.id
  acl    = "private"
}

# https://docs.aws.amazon.com/AmazonS3/latest/userguide/Versioning.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning
resource "aws_s3_bucket_versioning" "bastion" {
  bucket = aws_s3_bucket.bastion.id
  versioning_configuration {
    status = "Enabled"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
# https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-control-block-public-access.html
resource "aws_s3_bucket_public_access_block" "bastion" {
  bucket = aws_s3_bucket.bastion.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions
resource "aws_s3_bucket_policy" "bastion_load_balancer" {
  bucket = aws_s3_bucket.bastion.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = "arn:aws:s3:::${aws_s3_bucket.bastion.id}"
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${lookup(local.elb_account_ids, var.region)}:root"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.bastion.id}/${local.bucket_prefix}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.bastion.id}/${local.bucket_prefix}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# ====================================================================================================
#  DATA
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity
data "aws_caller_identity" "current" {}
