# certificate

This module can be used for creating TLS certificates using [AWS Certificate Manager](https://aws.amazon.com/certificate-manager) (ACM).

```hcl
module "certificate" {
  source = "github.com/gardenbed/terraform-modules/aws/certificate"

  domain           = "example.com"
  cert_domain      = "api.example.com"
  cert_alt_domains = [ "app.example.com" ]
}
```
