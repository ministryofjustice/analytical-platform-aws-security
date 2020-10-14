SHELL = /bin/bash

plan:
	terraform plan -var-file=vars/ap_accounts.tfvars -var-file=terraform.tfvars -var-file=endpoint.tfvars

init:
	terraform init

apply:
	terraform apply -var-file=vars/ap_accounts.tfvars -var-file=terraform.tfvars -var-file=endpoint.tfvars
