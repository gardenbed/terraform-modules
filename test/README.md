# Test

## AWS

A `terraform.tfvars` file is expected in `aws` directory with the following content:

```toml
access_key = "tbd"
secret_key = "tbd"
region     = "tbd"
```

You can run the tests using the standard `go test` command.
The only important thing is setting the `timeout` long enough, so Terraform resources can be provisioned and destroyed successfully.

    go test -timeout=30m ./aws

## Google

An `account.json` credential file is expected in `google` directory as well as a `terraform.tfvars` file with the following content:

```toml
project = "tbd"
region  = "tbd"
```

You can run the tests using the standard `go test` command.
The only important thing is setting the `timeout` long enough, so Terraform resources can be provisioned and destroyed successfully.

    go test -timeout=30m ./google

## Resources

  - **Terratest**
    - [Timeouts and logging](https://terratest.gruntwork.io/docs/testing-best-practices/timeouts-and-logging)
