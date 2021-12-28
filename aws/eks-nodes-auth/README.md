# eks-nodes-auth

This module deploys the `aws-auth` *ConfigMap* for self-managed nodes in an EKS cluster.
This needs to be a separate module due to the fact that all self-managed nodes require only one `aws-auth` *ConfigMap*.

## Usage

```hcl
module "nodes_auth" {
  source = "github.com/gardenbed/terraform-modules/aws/eks-nodes-auth"

  iam_role_arns = [ ... ]
}
```
