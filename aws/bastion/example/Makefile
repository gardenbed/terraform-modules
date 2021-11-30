ssh_path := ssh
key_name := $(ssh_path)/bastion

.PHONY: keys
keys:
	@ mkdir -p $(ssh_path)
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
	    -var ssh_path=$(ssh_path) \
	    -var private_key_file=$(key_name).pem \
	    -var public_key_file=$(key_name).pub

.PHONY: apply
apply:
	@ terraform apply \
	    -var ssh_path=$(ssh_path) \
	    -var private_key_file=$(key_name).pem \
	    -var public_key_file=$(key_name).pub

.PHONY: destroy
destroy:
	@ terraform destroy \
	    -var ssh_path=$(ssh_path) \
	    -var private_key_file=$(key_name).pem \
	    -var public_key_file=$(key_name).pub

.PHONY: clean
clean:
	@ rm -rf $(ssh_path) && \
	  rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
