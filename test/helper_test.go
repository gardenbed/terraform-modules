package test

import (
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
)

const (
	awsTFVarsFile         = "aws.tfvars"
	googleTFVarsFile      = "google.tfvars"
	googleCredentialsFile = "account.json"
	sshPath               = "ssh"
)

var (
	letters = []rune("abcdefghijklmnopqrstuvwxyz")
)

func getAWSTFVarsFile(t *testing.T) string {
	file, err := filepath.Abs(awsTFVarsFile)
	assert.NoError(t, err)

	return file
}

func getGoogleTFVarsFile(t *testing.T) string {
	file, err := filepath.Abs(googleTFVarsFile)
	assert.NoError(t, err)

	return file
}

func getGoogleCredentialsFile(t *testing.T) string {
	file, err := filepath.Abs(googleCredentialsFile)
	assert.NoError(t, err)

	return file
}
