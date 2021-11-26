# https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
#
# https://www.terraform.io/docs/language/meta-arguments/lifecycle.html#ignore_changes
#   We ignore changes to tags since they can take new values on each run (terraform plan/apply).
#   These updates are based on semantic rules managed outside of the Terraform scope.

# ====================================================================================================
#  OIDC
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/tls_certificate
data "tls_certificate" "cluster" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider
resource "aws_iam_openid_connect_provider" "cluster" {
  count = var.enable_iam_role_service_account ? 1 : 0

  url             = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  client_id_list  = [ "sts.amazonaws.com" ]
  thumbprint_list = [ data.tls_certificate.cluster.certificates[0].sha1_fingerprint]

  tags = merge(var.common_tags, {
    "Name" = format("%s-cluster-oidc", var.name)
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

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "cluster_service_account" {
  count = var.enable_iam_role_service_account ? 1 : 0

  statement {
    actions = [ "sts:AssumeRoleWithWebIdentity" ]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.cluster.0.url, "https://", "")}:sub"
      values   = [ "system:serviceaccount:kube-system:aws-node" ]
    }

    principals {
      identifiers = [ aws_iam_openid_connect_provider.cluster.0.arn ]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "cluster_service_account" {
  count = var.enable_iam_role_service_account ? 1 : 0

  name               = "${var.name}-cluster-service-account"
  assume_role_policy = data.aws_iam_policy_document.cluster_service_account.0.json
}
