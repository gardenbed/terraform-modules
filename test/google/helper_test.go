package google

import (
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
)

const (
	googleVarFile         = "terraform.tfvars"
	googleCredentialsFile = "account.json"
)

func getVarFile(t *testing.T) string {
	file, err := filepath.Abs(googleVarFile)
	assert.NoError(t, err)

	return file
}

func getCredentialsFile(t *testing.T) string {
	file, err := filepath.Abs(googleCredentialsFile)
	assert.NoError(t, err)

	return file
}
