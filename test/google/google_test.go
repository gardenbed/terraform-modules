package google

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraform_Google_Network(t *testing.T) {
	t.Parallel()

	logger.Log(t, "Running tests for google/network module ...")

	opts := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../google/network/example",

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
