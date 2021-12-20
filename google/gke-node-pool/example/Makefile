ssh_user := admin
ssh_path := ssh
bastion_key := $(ssh_path)/bastion
node_pool_key := $(ssh_path)/node-pool


terraform.tfvars:
	@ echo 'name    = "tbd"' >> terraform.tfvars
	@ echo 'project = "tbd"' >> terraform.tfvars
	@ echo 'region  = "tbd"' >> terraform.tfvars

.PHONY: keys
keys:
	@ mkdir -p $(ssh_path)
	@ ssh-keygen -f $(bastion_key) -t rsa -N '' -C $(ssh_user) 1> /dev/null && \
	  chmod 400 $(bastion_key) && \
	  mv $(bastion_key) $(bastion_key).pem
	@ ssh-keygen -f $(node_pool_key) -t rsa -N '' -C $(ssh_user) 1> /dev/null && \
	  chmod 400 $(node_pool_key) && \
	  mv $(node_pool_key) $(node_pool_key).pem

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
	    -var bastion_private_key_file=$(bastion_key).pem \
	    -var bastion_public_key_file=$(bastion_key).pub \
	    -var node_pool_private_key_file=$(node_pool_key).pem \
	    -var node_pool_public_key_file=$(node_pool_key).pub

.PHONY: apply
apply:
	@ terraform apply \
	    -var bastion_private_key_file=$(bastion_key).pem \
	    -var bastion_public_key_file=$(bastion_key).pub \
	    -var node_pool_private_key_file=$(node_pool_key).pem \
	    -var node_pool_public_key_file=$(node_pool_key).pub

.PHONY: refresh
refresh:
	@ terraform refresh \
	    -var bastion_private_key_file=$(bastion_key).pem \
	    -var bastion_public_key_file=$(bastion_key).pub \
	    -var node_pool_private_key_file=$(node_pool_key).pem \
	    -var node_pool_public_key_file=$(node_pool_key).pub

.PHONY: destroy
destroy:
	@ terraform destroy \
	    -var bastion_private_key_file=$(bastion_key).pem \
	    -var bastion_public_key_file=$(bastion_key).pub \
	    -var node_pool_private_key_file=$(node_pool_key).pem \
	    -var node_pool_public_key_file=$(node_pool_key).pub

.PHONY: clean
clean:
	@ rm -rf $(ssh_path) kubeconfig-* && \
	  rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
