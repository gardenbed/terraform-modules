# Test

Terraform does not officially support testing as of now.
There are currently two approaches for testing Terraform modules in the community.
One approach is writting tests in an imperative languages such as Go.
Another approach is using Terraform itself for writing tests.
You can read more about the future of testing in Terraform [here](https://www.terraform.io/language/modules/testing-experiment).

The Terraform support for testing is experimental and still very early to adopt.
We use [Terratest](https://terratest.gruntwork.io) for testing Terraform modules in this repository.
The tests are written in [Go](https://go.dev) and can be managed using the standard `go` commands and tooling.

## AWS

A `terraform.tfvars` file is expected in `aws` directory with the following content:

```toml
access_key = "tbd"
secret_key = "tbd"
region     = "tbd"
```

You can run the tests using the standard `go test` command.
The only important thing is setting the `timeout` long enough, so Terraform resources can be provisioned and destroyed successfully.

    go test -v -timeout=60m ./aws

## Google

An `account.json` credential file is expected in `google` directory as well as a `terraform.tfvars` file with the following content:

```toml
project = "tbd"
region  = "tbd"
```

You can run the tests using the standard `go test` command.
The only important thing is setting the `timeout` long enough, so Terraform resources can be provisioned and destroyed successfully.

    go test -v -timeout=60m ./google

## Resources

  - [Module Testing Experiment](https://www.terraform.io/language/modules/testing-experiment)
  - **Terratest**
    - [Timeouts and logging](https://terratest.gruntwork.io/docs/testing-best-practices/timeouts-and-logging)
