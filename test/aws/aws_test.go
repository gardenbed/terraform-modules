package aws

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraform_AWS_Network(t *testing.T) {
	t.Parallel()

	logger.Log(t, "Running tests for aws/network module ...")

	opts := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../aws/network/example",

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
