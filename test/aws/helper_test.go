package aws

import (
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
)

const (
	awsVarFile = "terraform.tfvars"
)

func getVarFile(t *testing.T) string {
	file, err := filepath.Abs(awsVarFile)
	assert.NoError(t, err)

	return file
}
