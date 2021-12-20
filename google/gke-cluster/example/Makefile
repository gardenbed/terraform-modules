credentials_file := ../../account.json


terraform.tfvars:
	@ echo 'name    = "tbd"' >> terraform.tfvars
	@ echo 'project = "tbd"' >> terraform.tfvars
	@ echo 'region  = "tbd"' >> terraform.tfvars

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
	    -var credentials_file=$(credentials_file)

.PHONY: apply
apply:
	@ terraform apply \
	    -var credentials_file=$(credentials_file)

.PHONY: refresh
refresh:
	@ terraform refresh \
	    -var credentials_file=$(credentials_file)

.PHONY: destroy
destroy:
	@ terraform destroy \
	    -var credentials_file=$(credentials_file)

.PHONY: clean
clean:
	@ rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
