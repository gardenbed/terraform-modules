package test

import (
	"fmt"
	"io/ioutil"
	"math/rand"
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/ssh"
)

const (
	sshPath = "ssh"
)

var (
	rnd     = rand.New(rand.NewSource(time.Now().UnixNano()))
	letters = []rune("abcdefghijklmnopqrstuvwxyz")
)

type SSHKeyPair struct {
	*ssh.KeyPair
	PublicFile  string
	PrivateFile string
}

func (k *SSHKeyPair) Clean() {
	_ = os.Remove(k.PublicFile)
	_ = os.Remove(k.PrivateFile)
}

func CreateSSHKeyPair(t *testing.T, prefix string) (*SSHKeyPair, error) {
	pair, err := ssh.GenerateRSAKeyPairE(t, 4096)
	if err != nil {
		return nil, err
	}

	if err := os.MkdirAll(sshPath, 0700); err != nil {
		return nil, err
	}

	name := fmt.Sprintf("%s-%s", prefix, randSuffix())

	publicFile, err := filepath.Abs(filepath.Join(sshPath, name+".pub"))
	if err != nil {
		return nil, err
	}

	privateFile, err := filepath.Abs(filepath.Join(sshPath, name+".pem"))
	if err != nil {
		return nil, err
	}

	// Write public file (-rw-r--r--)
	if err := ioutil.WriteFile(publicFile, []byte(pair.PublicKey), 0644); err != nil {
		return nil, err
	}

	// Write private file (-rw-------)
	if err := ioutil.WriteFile(privateFile, []byte(pair.PrivateKey), 0600); err != nil {
		return nil, err
	}

	return &SSHKeyPair{
		KeyPair:     pair,
		PublicFile:  publicFile,
		PrivateFile: privateFile,
	}, nil
}

func randSuffix() string {
	b := make([]rune, 2)
	for i := range b {
		b[i] = letters[rnd.Intn(len(letters))]
	}

	return fmt.Sprintf("%s%d", string(b), rnd.Intn(100))
}
