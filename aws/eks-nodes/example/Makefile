ssh_path := ssh
bastion_key_file := $(ssh_path)/bastion
nodes_key_file := $(ssh_path)/nodes


terraform.tfvars:
	@ echo 'access_key = "tbd"' >> terraform.tfvars
	@ echo 'secret_key = "tbd"' >> terraform.tfvars
	@ echo 'region     = "tbd"' >> terraform.tfvars
	@ echo 'name       = "eks-nodes-example"' >> terraform.tfvars

.PHONY: keys
keys:
	@ mkdir -p $(ssh_path)
	@ ssh-keygen -f $(bastion_key_file) -t rsa -N '' 1> /dev/null && \
	  chmod 400 $(bastion_key_file) && \
	  mv $(bastion_key_file) $(bastion_key_file).pem
	@ ssh-keygen -f $(nodes_key_file) -t rsa -N '' 1> /dev/null && \
	  chmod 400 $(nodes_key_file) && \
	  mv $(nodes_key_file) $(nodes_key_file).pem

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
	    -var bastion_public_key_file=$(bastion_key_file).pub \
	    -var bastion_private_key_file=$(bastion_key_file).pem \
	    -var nodes_public_key_file=$(nodes_key_file).pub \
	    -var nodes_private_key_file=$(nodes_key_file).pem

.PHONY: apply
apply:
	@ terraform apply \
	    -var bastion_public_key_file=$(bastion_key_file).pub \
	    -var bastion_private_key_file=$(bastion_key_file).pem \
	    -var nodes_public_key_file=$(nodes_key_file).pub \
	    -var nodes_private_key_file=$(nodes_key_file).pem

.PHONY: refresh
refresh:
	@ terraform refresh \
	    -var bastion_public_key_file=$(bastion_key_file).pub \
	    -var bastion_private_key_file=$(bastion_key_file).pem \
	    -var nodes_public_key_file=$(nodes_key_file).pub \
	    -var nodes_private_key_file=$(nodes_key_file).pem

.PHONY: destroy
destroy:
	@ terraform destroy \
	    -var bastion_public_key_file=$(bastion_key_file).pub \
	    -var bastion_private_key_file=$(bastion_key_file).pem \
	    -var nodes_public_key_file=$(nodes_key_file).pub \
	    -var nodes_private_key_file=$(nodes_key_file).pem

.PHONY: clean
clean:
	@ rm -rf $(ssh_path) kubeconfig-* && \
	  rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
