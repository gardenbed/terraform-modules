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
	    -var bastion_public_key_file=$(key_name).pub

.PHONY: apply
apply:
	@ terraform apply \
	    -var bastion_public_key_file=$(key_name).pub

.PHONY: destroy
destroy:
	@ terraform destroy \
	    -var bastion_public_key_file=$(key_name).pub

.PHONY: clean
clean:
	@ rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
