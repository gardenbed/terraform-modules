# eks-nodes-auth

This module deploys the `aws-auth` *ConfigMap* for self-managed nodes in an EKS cluster.
This needs to be a separate module due to the fact that all self-managed nodes require only one `aws-auth` *ConfigMap*.
