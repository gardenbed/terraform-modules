# ====================================================================================================
#  Kubernetes Resources
# ====================================================================================================

# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map
# If the cluster has node groups, the `aws-auth` ConfigMap is already created.
# Only one `aws-auth` ConfigMap should be created for all nodes.
resource "kubernetes_config_map" "aws_auth" {
  metadata {  
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode(
      distinct([
        for iam_role_arn in var.iam_role_arns: {
          rolearn  = iam_role_arn
          username = "system:node:{{EC2PrivateDNSName}}"
          groups   = [
            "system:bootstrappers",
            "system:nodes",
          ]
        }
      ])
    )
  }
}
