ssh_path := ssh
bastion_key := $(ssh_path)/bastion
nodes_key := $(ssh_path)/nodes


.PHONY: keys
keys:
	@ mkdir -p $(ssh_path)
	@ ssh-keygen -f $(bastion_key) -t rsa -N '' 1> /dev/null && \
	  chmod 400 $(bastion_key) && \
	  mv $(bastion_key) $(bastion_key).pem
	@ ssh-keygen -f $(nodes_key) -t rsa -N '' 1> /dev/null && \
	  chmod 400 $(nodes_key) && \
	  mv $(nodes_key) $(nodes_key).pem

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
	    -var nodes_private_key_file=$(nodes_key).pem \
	    -var nodes_public_key_file=$(nodes_key).pub

.PHONY: apply
apply:
	@ terraform apply \
	    -var ssh_path=$(ssh_path) \
	    -var bastion_private_key_file=$(bastion_key).pem \
	    -var bastion_public_key_file=$(bastion_key).pub \
	    -var nodes_private_key_file=$(nodes_key).pem \
	    -var nodes_public_key_file=$(nodes_key).pub

.PHONY: refresh
refresh:
	@ terraform refresh \
	    -var ssh_path=$(ssh_path) \
	    -var bastion_private_key_file=$(bastion_key).pem \
	    -var bastion_public_key_file=$(bastion_key).pub \
	    -var nodes_private_key_file=$(nodes_key).pem \
	    -var nodes_public_key_file=$(nodes_key).pub

.PHONY: destroy
destroy:
	@ terraform destroy \
	    -var ssh_path=$(ssh_path) \
	    -var bastion_private_key_file=$(bastion_key).pem \
	    -var bastion_public_key_file=$(bastion_key).pub \
	    -var nodes_private_key_file=$(nodes_key).pem \
	    -var nodes_public_key_file=$(nodes_key).pub

.PHONY: clean
clean:
	@ rm -rf $(ssh_path) kubeconfig-* && \
	  rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
