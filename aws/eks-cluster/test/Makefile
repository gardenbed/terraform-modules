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
	@ terraform plan

.PHONY: apply
apply:
	@ terraform apply

.PHONY: destroy
destroy:
	@ terraform destroy

.PHONY: clean
clean:
	@ rm -f kubeconfig-* && \
	  rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
