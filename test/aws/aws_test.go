package aws

import (
	"errors"
	"fmt"
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

	t.Run("TestSSH", func(t *testing.T) {
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

func TestTerraform_AWS_EKS_Node_Group(t *testing.T) {
	t.Parallel()

	logger.Log(t, "Running tests for aws/eks-node-group module ...")

	logger.Log(t, "Generating SSH keys for bastion hosts ...")
	bastionKeypair, err := test.CreateSSHKeyPair(t, "bastion")
	assert.NoError(t, err)
	defer bastionKeypair.Clean()

	logger.Log(t, "Generating SSH keys for node group ...")
	nodeKeypair, err := test.CreateSSHKeyPair(t, "node-group")
	assert.NoError(t, err)
	defer nodeKeypair.Clean()

	opts := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../aws/eks-node-group/example",

		// The var file paths to pass to Terraform commands using -var-file option
		VarFiles: []string{
			getVarFile(t),
		},

		// The variables to pass to Terraform commands using the -var option
		Vars: map[string]interface{}{
			"name":                        "eks-node-group-test",
			"kubeconfig_path":             getCurrentDir(t),
			"bastion_public_key_file":     bastionKeypair.PublicFile,
			"bastion_private_key_file":    bastionKeypair.PrivateFile,
			"node_group_public_key_file":  nodeKeypair.PublicFile,
			"node_group_private_key_file": nodeKeypair.PrivateFile,
		},
	})

	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)

	t.Run("VerifyOutputs", func(t *testing.T) {
		assert.NotEmpty(t, terraform.Output(t, opts, "cluster_name"))
		assert.NotEmpty(t, terraform.Output(t, opts, "cluster_version"))
		assert.NotEmpty(t, terraform.Output(t, opts, "cluster_status"))
		assert.NotEmpty(t, terraform.Output(t, opts, "cluster_endpoint"))
		assert.NotEmpty(t, terraform.Output(t, opts, "cluster_oidc_url"))
		assert.NotEmpty(t, terraform.Output(t, opts, "node_group_name"))
		assert.NotEmpty(t, terraform.Output(t, opts, "node_group_status"))
		assert.NotEmpty(t, terraform.Output(t, opts, "node_group_instances"))
		assert.NotEmpty(t, terraform.Output(t, opts, "bastion_address"))
		assert.NotEmpty(t, terraform.Output(t, opts, "kubeconfig_file"))
		assert.NotEmpty(t, terraform.Output(t, opts, "ssh_config_file"))
	})

	t.Run("TestNodeSSH", func(t *testing.T) {
		bastionAddr := terraform.Output(t, opts, "bastion_address")

		instances := terraform.OutputListOfObjects(t, opts, "node_group_instances")
		if len(instances) == 0 {
			t.FailNow()
		}

		privateIP, exist := instances[0]["private_ip"]
		if !exist {
			t.FailNow()
		}

		nodeAddr, ok := privateIP.(string)
		if !ok {
			t.FailNow()
		}

		publicHost := ssh.Host{
			Hostname:    bastionAddr,
			SshKeyPair:  bastionKeypair.KeyPair,
			SshUserName: "admin",
		}

		privateHost := ssh.Host{
			Hostname:    nodeAddr,
			SshKeyPair:  nodeKeypair.KeyPair,
			SshUserName: "ec2-user",
		}

		retryCount := 30
		retryPeriod := 10 * time.Second
		description := fmt.Sprintf("SSH to node %s via bastion host %s", nodeAddr, bastionAddr)

		retry.DoWithRetry(t, description, retryCount, retryPeriod, func() (string, error) {
			instanceID, err := ssh.CheckPrivateSshConnectionE(t, publicHost, privateHost, `curl -s http://169.254.169.254/latest/meta-data/instance-id`)
			if err != nil {
				return "", err
			}

			if instanceID == "" {
				return "", errors.New("unexpected instance id for node")
			}

			logger.Log(t, "Node instance ID:", instanceID)

			return "OK", nil
		})
	})

	t.Run("TestClusterConnection", func(t *testing.T) {
		clusterName := terraform.Output(t, opts, "cluster_name")
		kubeconfigFile := terraform.Output(t, opts, "kubeconfig_file")
		opts := k8s.NewKubectlOptions(clusterName, kubeconfigFile, "default")

		retryCount := 30
		retryPeriod := 10 * time.Second
		description := fmt.Sprintf("Connecting to EKS cluster %s", clusterName)

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

func TestTerraform_AWS_EKS_Nodes(t *testing.T) {
	t.Parallel()

	logger.Log(t, "Running tests for aws/eks-nodes module ...")

	logger.Log(t, "Generating SSH keys for bastion hosts ...")
	bastionKeypair, err := test.CreateSSHKeyPair(t, "bastion")
	assert.NoError(t, err)
	defer bastionKeypair.Clean()

	logger.Log(t, "Generating SSH keys for nodes ...")
	nodeKeypair, err := test.CreateSSHKeyPair(t, "nodes")
	assert.NoError(t, err)
	defer nodeKeypair.Clean()

	opts := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../aws/eks-nodes/example",

		// The var file paths to pass to Terraform commands using -var-file option
		VarFiles: []string{
			getVarFile(t),
		},

		// The variables to pass to Terraform commands using the -var option
		Vars: map[string]interface{}{
			"name":                     "eks-nodes-test",
			"kubeconfig_path":          getCurrentDir(t),
			"bastion_public_key_file":  bastionKeypair.PublicFile,
			"bastion_private_key_file": bastionKeypair.PrivateFile,
			"nodes_public_key_file":    nodeKeypair.PublicFile,
			"nodes_private_key_file":   nodeKeypair.PrivateFile,
		},
	})

	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)

	t.Run("VerifyOutputs", func(t *testing.T) {
		assert.NotEmpty(t, terraform.Output(t, opts, "cluster_name"))
		assert.NotEmpty(t, terraform.Output(t, opts, "cluster_version"))
		assert.NotEmpty(t, terraform.Output(t, opts, "cluster_status"))
		assert.NotEmpty(t, terraform.Output(t, opts, "cluster_endpoint"))
		assert.NotEmpty(t, terraform.Output(t, opts, "cluster_oidc_url"))
		assert.NotEmpty(t, terraform.Output(t, opts, "node_instances"))
		assert.NotEmpty(t, terraform.Output(t, opts, "bastion_address"))
		assert.NotEmpty(t, terraform.Output(t, opts, "kubeconfig_file"))
		assert.NotEmpty(t, terraform.Output(t, opts, "ssh_config_file"))
	})

	t.Run("TestNodeSSH", func(t *testing.T) {
		bastionAddr := terraform.Output(t, opts, "bastion_address")

		instances := terraform.OutputListOfObjects(t, opts, "node_instances")
		if len(instances) == 0 {
			t.FailNow()
		}

		privateIP, exist := instances[0]["private_ip"]
		if !exist {
			t.FailNow()
		}

		nodeAddr, ok := privateIP.(string)
		if !ok {
			t.FailNow()
		}

		publicHost := ssh.Host{
			Hostname:    bastionAddr,
			SshKeyPair:  bastionKeypair.KeyPair,
			SshUserName: "admin",
		}

		privateHost := ssh.Host{
			Hostname:    nodeAddr,
			SshKeyPair:  nodeKeypair.KeyPair,
			SshUserName: "ec2-user",
		}

		retryCount := 30
		retryPeriod := 10 * time.Second
		description := fmt.Sprintf("SSH to node %s via bastion host %s", nodeAddr, bastionAddr)

		retry.DoWithRetry(t, description, retryCount, retryPeriod, func() (string, error) {
			instanceID, err := ssh.CheckPrivateSshConnectionE(t, publicHost, privateHost, `curl -s http://169.254.169.254/latest/meta-data/instance-id`)
			if err != nil {
				return "", err
			}

			if instanceID == "" {
				return "", errors.New("unexpected instance id for node")
			}

			logger.Log(t, "Node instance ID:", instanceID)

			return "OK", nil
		})
	})

	t.Run("TestClusterConnection", func(t *testing.T) {
		clusterName := terraform.Output(t, opts, "cluster_name")
		kubeconfigFile := terraform.Output(t, opts, "kubeconfig_file")
		opts := k8s.NewKubectlOptions(clusterName, kubeconfigFile, "default")

		retryCount := 30
		retryPeriod := 10 * time.Second
		description := fmt.Sprintf("Connecting to EKS cluster %s", clusterName)

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
