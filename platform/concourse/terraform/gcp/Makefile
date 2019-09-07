.PHONY: help fmt plan apply destroy

gcp_ssh_user = $(shell whoami)

plan: ## Perform terraform plan with output file
	@terraform plan -out=plan #-var gcp_ssh_user=${gcp_ssh_user}

apply: ## Perform terraform apply plan
	@terraform apply plan

destroy: ## Perform terraform destroy -f -var env=${tf_env}
	@terraform destroy -force


fmt: ## Format terraform files with terraform fmt
	@terraform fmt



help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

