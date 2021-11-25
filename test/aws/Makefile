name := $(shell cat terraform.tfvars | grep name | grep -oe '".*"')
region := $(shell cat terraform.tfvars | grep region | grep -oe '".*"')
key_name := $(name)-$(region)-bastion

uuid := $(shell uuidgen)
owner := $(shell whoami)
branch := $(shell git rev-parse --abbrev-ref HEAD)
commit := $(shell git rev-parse --short HEAD)


.PHONY: clean
clean:
	@ rm -f *.pub *.pem $(key_name) && \
	  rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup

.PHONY: keys
keys:
	@ ssh-keygen -f $(key_name) -t rsa -N '' 1> /dev/null && \
	  chmod 400 $(key_name) && \
	  mv $(key_name) $(key_name).pem

.PHONY: init
init:
	@ terraform init

.PHONY: format
format:
	@ terraform fmt

.PHONY: validate
validate:
	@ terraform validate

.PHONY: plan
plan:
	@ terraform plan \
	    -var uuid=$(uuid) \
	    -var owner=$(owner) \
	    -var git_branch=$(branch) \
	    -var git_commit=$(commit) \
	    -var bastion_key_name=$(key_name)

.PHONY: apply
apply:
	@ terraform apply \
	    -var uuid=$(uuid) \
	    -var owner=$(owner) \
	    -var git_branch=$(branch) \
	    -var git_commit=$(commit) \
	    -var bastion_key_name=$(key_name)

.PHONY: destroy
destroy:
	@ terraform destroy \
	    -var uuid=$(uuid) \
	    -var owner=$(owner) \
	    -var git_branch=$(branch) \
	    -var git_commit=$(commit) \
	    -var bastion_key_name=$(key_name)
