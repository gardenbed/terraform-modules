package google

import (
	"errors"
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"

	"github.com/gardenbed/terraform-modules/test"
)

func TestTerraform_Google_Network(t *testing.T) {
	t.Parallel()

	logger.Log(t, "Running tests for google/network module ...")

	opts := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../google/network/example",

		// The var file paths to pass to Terraform commands using -var-file option
		VarFiles: []string{
			getVarFile(t),
		},

		// The variables to pass to Terraform commands using the -var option
		Vars: map[string]interface{}{
			"credentials_file": getCredentialsFile(t),
			"name":             "network-test",
		},
	})

	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)

	t.Run("VerifyOutputs", func(t *testing.T) {
		assert.NotEmpty(t, terraform.Output(t, opts, "network"))
		assert.NotEmpty(t, terraform.Output(t, opts, "public_subnetwork"))
		assert.NotEmpty(t, terraform.Output(t, opts, "private_subnetwork"))
	})
}

func TestTerraform_Google_Bastion(t *testing.T) {
	t.Parallel()

	logger.Log(t, "Running tests for google/bastion module ...")

	logger.Log(t, "Generating SSH keys ...")
	keypair, err := test.CreateSSHKeyPair(t, "bastion")
	assert.NoError(t, err)
	defer keypair.Clean()

	opts := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../google/bastion/example",

		// The var file paths to pass to Terraform commands using -var-file option
		VarFiles: []string{
			getVarFile(t),
		},

		// The variables to pass to Terraform commands using the -var option
		Vars: map[string]interface{}{
			"credentials_file":     getCredentialsFile(t),
			"name":                 "bastion-test",
			"ssh_public_key_file":  keypair.PublicFile,
			"ssh_private_key_file": keypair.PrivateFile,
		},
	})

	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)

	t.Run("VerifyOutputs", func(t *testing.T) {
		assert.NotEmpty(t, terraform.Output(t, opts, "address"))
		assert.NotEmpty(t, terraform.Output(t, opts, "ssh_config_file"))
	})

	t.Run("TestConnection", func(t *testing.T) {
		address := terraform.Output(t, opts, "address")
		host := ssh.Host{
			Hostname:    address,
			SshKeyPair:  keypair.KeyPair,
			SshUserName: "admin",
		}

		retryCount := 30
		retryPeriod := 10 * time.Second
		description := fmt.Sprintf("SSH to bastion instance %s", address)

		retry.DoWithRetry(t, description, retryCount, retryPeriod, func() (string, error) {
			tags, err := ssh.CheckSshCommandE(t, host, `curl -s -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/tags"`)
			if err != nil {
				return "", err
			}

			if !strings.Contains(tags, "bastion") {
				return "", errors.New("unexpected tags for bastion instance")
			}

			logger.Log(t, "Instance tags:", tags)

			return tags, nil
		})
	})
}
