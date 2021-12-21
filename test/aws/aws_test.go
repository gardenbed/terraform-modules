package aws

import (
	"errors"
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"

	"github.com/gardenbed/terraform-modules/test"
)

func TestTerraform_AWS_Network(t *testing.T) {
	t.Parallel()

	logger.Log(t, "Running tests for aws/network module ...")

	opts := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../aws/network/example",

		// The var file paths to pass to Terraform commands using -var-file option
		VarFiles: []string{
			getVarFile(t),
		},

		// The variables to pass to Terraform commands using the -var option
		Vars: map[string]interface{}{
			"name": "network-test",
		},
	})

	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)

	t.Run("VerifyOutputs", func(t *testing.T) {
		assert.NotEmpty(t, terraform.Output(t, opts, "vpc"))
		assert.NotEmpty(t, terraform.Output(t, opts, "public_subnets"))
		assert.NotEmpty(t, terraform.Output(t, opts, "private_subnets"))
	})
}

func TestTerraform_AWS_Bastion(t *testing.T) {
	t.Parallel()

	logger.Log(t, "Running tests for aws/bastion module ...")

	logger.Log(t, "Generating SSH keys ...")
	keypair, err := test.CreateSSHKeyPair(t, "bastion")
	assert.NoError(t, err)
	defer keypair.Clean()

	opts := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../aws/bastion/example",

		// The var file paths to pass to Terraform commands using -var-file option
		VarFiles: []string{
			getVarFile(t),
		},

		// The variables to pass to Terraform commands using the -var option
		Vars: map[string]interface{}{
			"name":                 "bastion-test",
			"ssh_public_key_file":  keypair.PublicFile,
			"ssh_private_key_file": keypair.PrivateFile,
		},
	})

	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)

	t.Run("VerifyOutputs", func(t *testing.T) {
		assert.NotEmpty(t, terraform.Output(t, opts, "load_balancer_dns_name"))
		assert.NotEmpty(t, terraform.Output(t, opts, "load_balancer_public_ips"))
		assert.NotEmpty(t, terraform.Output(t, opts, "ssh_config_file"))
	})

	t.Run("TestConnection", func(t *testing.T) {
		address := terraform.Output(t, opts, "load_balancer_dns_name")
		host := ssh.Host{
			Hostname:    address,
			SshKeyPair:  keypair.KeyPair,
			SshUserName: "admin",
		}

		retryCount := 30
		retryPeriod := 10 * time.Second
		description := fmt.Sprintf("SSH to bastion host %s", address)

		retry.DoWithRetry(t, description, retryCount, retryPeriod, func() (string, error) {
			instanceID, err := ssh.CheckSshCommandE(t, host, `curl -s http://169.254.169.254/latest/meta-data/instance-id`)
			if err != nil {
				return "", err
			}

			if instanceID == "" {
				return "", errors.New("unexpected instance id for bastion host")
			}

			logger.Log(t, "Instance ID:", instanceID)

			return instanceID, nil
		})
	})
}
