package aws

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
)

const (
	awsVarFile = "terraform.tfvars"
)

func getCurrentDir(t *testing.T) string {
	dir, err := os.Getwd()
	assert.NoError(t, err)

	return dir
}

func getVarFile(t *testing.T) string {
	file, err := filepath.Abs(awsVarFile)
	assert.NoError(t, err)

	return file
}
