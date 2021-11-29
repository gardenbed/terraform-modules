uuid := $(shell uuidgen)
owner := $(shell whoami)
branch := $(shell git rev-parse --abbrev-ref HEAD)
commit := $(shell git rev-parse --short HEAD)


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
	    -var git_commit=$(commit)

.PHONY: apply
apply:
	@ terraform apply \
	    -var uuid=$(uuid) \
	    -var owner=$(owner) \
	    -var git_branch=$(branch) \
	    -var git_commit=$(commit)

.PHONY: destroy
destroy:
	@ terraform destroy \
	    -var uuid=$(uuid) \
	    -var owner=$(owner) \
	    -var git_branch=$(branch) \
	    -var git_commit=$(commit)

.PHONY: clean
clean:
	@ rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
