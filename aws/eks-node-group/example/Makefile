ssh_path := ssh
bastion_key := $(ssh_path)/bastion
node_group_key := $(ssh_path)/node-group


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
	    -var bastion_private_key_file=$(bastion_key).pem \
	    -var bastion_public_key_file=$(bastion_key).pub \
	    -var node_group_private_key_file=$(node_group_key).pem \
	    -var node_group_public_key_file=$(node_group_key).pub

.PHONY: apply
apply:
	@ terraform apply \
	    -var ssh_path=$(ssh_path) \
	    -var bastion_private_key_file=$(bastion_key).pem \
	    -var bastion_public_key_file=$(bastion_key).pub \
	    -var node_group_private_key_file=$(node_group_key).pem \
	    -var node_group_public_key_file=$(node_group_key).pub

.PHONY: destroy
destroy:
	@ terraform destroy \
	    -var ssh_path=$(ssh_path) \
	    -var bastion_private_key_file=$(bastion_key).pem \
	    -var bastion_public_key_file=$(bastion_key).pub \
	    -var node_group_private_key_file=$(node_group_key).pem \
	    -var node_group_public_key_file=$(node_group_key).pub

.PHONY: clean
clean:
	@ rm -rf $(ssh_path) kubeconfig-* && \
	  rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
