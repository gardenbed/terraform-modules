# certificate

This module can be used for creating TLS certificates using [AWS Certificate Manager](https://aws.amazon.com/certificate-manager) (ACM).

## Usage

```hcl
module "certificate" {
  source = "github.com/gardenbed/terraform-modules/aws/certificate"

  domain           = "example.com"
  cert_domain      = "api.example.com"
  cert_alt_domains = [ "app.example.com" ]
}
```

## Documentation

`domain` is your main domain name and it used for getting the Route53 zone.
`cert_domain` is used for for your certificate and it can be a subdomain or same as your domain.
`cert_alt_domains` are secondary domain or subdomain names for your certificate.
