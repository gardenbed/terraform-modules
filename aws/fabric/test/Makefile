name := $(shell cat terraform.tfvars | grep name | grep -oe '".*"')
region := $(shell cat terraform.tfvars | grep region | grep -oe '".*"')
key_name := $(name)-$(region)-bastion


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
	    -var bastion_public_key=$(key_name).pub

.PHONY: apply
apply:
	@ terraform apply \
	    -var bastion_public_key=$(key_name).pub

.PHONY: destroy
destroy:
	@ terraform destroy \
	    -var bastion_public_key=$(key_name).pub

.PHONY: clean
clean:
	@ rm -f *.pub *.pem $(key_name) && \
	  rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
