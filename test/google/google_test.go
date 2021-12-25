package google

import (
	"errors"
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/k8s"
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

	t.Run("TestSSH", func(t *testing.T) {
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

func TestTerraform_Google_GKE_Node_Pool(t *testing.T) {
	t.Parallel()

	logger.Log(t, "Running tests for google/gke-node-pool module ...")

	logger.Log(t, "Generating SSH keys for bastion instances ...")
	bastionKeypair, err := test.CreateSSHKeyPair(t, "bastion")
	assert.NoError(t, err)
	defer bastionKeypair.Clean()

	logger.Log(t, "Generating SSH keys for node pool ...")
	nodeKeypair, err := test.CreateSSHKeyPair(t, "node-pool")
	assert.NoError(t, err)
	defer nodeKeypair.Clean()

	opts := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../google/gke-node-pool/example",

		// The var file paths to pass to Terraform commands using -var-file option
		VarFiles: []string{
			getVarFile(t),
		},

		// The variables to pass to Terraform commands using the -var option
		Vars: map[string]interface{}{
			"credentials_file":           getCredentialsFile(t),
			"name":                       "gke-node-pool-test",
			"kubeconfig_path":            getCurrentDir(t),
			"bastion_public_key_file":    bastionKeypair.PublicFile,
			"bastion_private_key_file":   bastionKeypair.PrivateFile,
			"node_pool_public_key_file":  nodeKeypair.PublicFile,
			"node_pool_private_key_file": nodeKeypair.PrivateFile,
		},
	})

	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)

	t.Run("VerifyOutputs", func(t *testing.T) {
		assert.NotEmpty(t, terraform.Output(t, opts, "cluster_id"))
		assert.NotEmpty(t, terraform.Output(t, opts, "cluster_name"))
		assert.NotEmpty(t, terraform.Output(t, opts, "cluster_version"))
		assert.NotEmpty(t, terraform.Output(t, opts, "cluster_services_cidr"))
		assert.NotEmpty(t, terraform.Output(t, opts, "cluster_endpoint"))
		assert.NotEmpty(t, terraform.Output(t, opts, "cluster_cluster_ca_cert"))
		assert.NotEmpty(t, terraform.Output(t, opts, "cluster_client_cert"))
		assert.NotEmpty(t, terraform.Output(t, opts, "cluster_client_key"))
		assert.NotEmpty(t, terraform.Output(t, opts, "cluster_service_account_email"))
		assert.NotEmpty(t, terraform.Output(t, opts, "node_pool_id"))
		assert.NotEmpty(t, terraform.Output(t, opts, "kubeconfig_file"))
		assert.NotEmpty(t, terraform.Output(t, opts, "ssh_config_file"))
	})

	t.Run("TestConnection", func(t *testing.T) {
		clusterName := terraform.Output(t, opts, "cluster_name")
		kubeconfigFile := terraform.Output(t, opts, "kubeconfig_file")
		opts := k8s.NewKubectlOptions(clusterName, kubeconfigFile, "default")

		retryCount := 30
		retryPeriod := 10 * time.Second
		description := fmt.Sprintf("Connecting to GKE cluster %s", clusterName)

		retry.DoWithRetry(t, description, retryCount, retryPeriod, func() (string, error) {
			nodes, err := k8s.GetNodesE(t, opts)
			if err != nil {
				return "", err
			}

			for _, node := range nodes {
				logger.Log(t, "Node name:", node.Name)
			}

			return "OK", nil
		})
	})
}
