# Terraform Modules

This is a central repository for all [Terraform](https://www.terraform.io) modules used by *GardenBed* projects.

The modules are organized by cloud provider, one directory per each provider (`aws`, `google`, etc.).
Tests are organized in a separate directory (`test`) by cloud provider, one directory per each provider (`test/aws`, `test/google`, etc.).

## References

  - [Version Constraints](https://www.terraform.io/docs/language/expressions/version-constraints.html)
  - [Terraform Settings](https://www.terraform.io/docs/language/settings/index.html)
  - [Backend Configuration](https://www.terraform.io/docs/language/settings/backends/configuration.html)
  - **Providers**
    - [Provider Requirements](https://www.terraform.io/docs/language/providers/requirements.html)
    - [Provider Configuration](https://www.terraform.io/docs/language/providers/configuration.html)
    - [Dependency Lock File](https://www.terraform.io/docs/language/dependency-lock.html)
  - **Modules**
    - [Standard Module Structure](https://www.terraform.io/docs/language/modules/develop/structure.html)
    - [Providers Within Modules](https://www.terraform.io/docs/language/modules/develop/providers.html)
    - [Module Composition](https://www.terraform.io/docs/language/modules/develop/composition.html)
    - [Publishing Modules](https://www.terraform.io/docs/language/modules/develop/publish.html)
