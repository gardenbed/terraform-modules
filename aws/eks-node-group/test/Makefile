name := $(shell cat terraform.tfvars | grep name | grep -oe '".*"')
region := $(shell cat terraform.tfvars | grep region | grep -oe '".*"')

ssh_path := ssh
bastion_key := $(ssh_path)/$(name)-bastion
node_group_key := $(ssh_path)/$(name)-node-group


.PHONY: keys
keys:
	@ mkdir -p $(ssh_path)
	@ ssh-keygen -f $(bastion_key) -t rsa -N '' 1> /dev/null && \
	  chmod 400 $(bastion_key) && \
	  mv $(bastion_key) $(bastion_key).pem
	@ ssh-keygen -f $(node_group_key) -t rsa -N '' 1> /dev/null && \
	  chmod 400 $(node_group_key) && \
	  mv $(node_group_key) $(node_group_key).pem

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
	    -var bastion_public_key=$(bastion_key).pub \
	    -var bastion_private_key=$(bastion_key).pem \
	    -var node_group_public_key=$(node_group_key).pub \
	    -var node_group_private_key=$(node_group_key).pem

.PHONY: apply
apply:
	@ terraform apply \
	    -var ssh_path=$(ssh_path) \
	    -var bastion_public_key=$(bastion_key).pub \
	    -var bastion_private_key=$(bastion_key).pem \
	    -var node_group_public_key=$(node_group_key).pub \
	    -var node_group_private_key=$(node_group_key).pem

.PHONY: destroy
destroy:
	@ terraform destroy \
	    -var ssh_path=$(ssh_path) \
	    -var bastion_public_key=$(bastion_key).pub \
	    -var bastion_private_key=$(bastion_key).pem \
	    -var node_group_public_key=$(node_group_key).pub \
	    -var node_group_private_key=$(node_group_key).pem

.PHONY: clean
clean:
	@ rm -rf $(ssh_path) kubeconfig-* && \
	  rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
