# https://makefiletutorial.com/
.PHONY: help \
		terraform-init \
		terraform-workspace terraform-fmt terraform-bootstrap terraform-destroy

.DEFAULT: help

# Set Shell
SHELL=/bin/bash

# Set list of env variables
ENV_VARS := AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION CLOUDFLARE_API_KEY CLOUDFLARE_EMAIL TZ TF_DIR

# Include env file
include .env

# Export env variable
export AWS_REGION:=us-east-1
export TF_DIR:=.

#TF_DIR ?= $(shell bash -c 'read -s -p "TF_DIR: " TF_DIR; echo $$TF_DIR')

# default target
#COLORS
GREEN  := $(shell [[ -t 0 ]] && tput -Txterm setaf 2)
WHITE  := $(shell [[ -t 0 ]] && tput -Txterm setaf 7)
YELLOW := $(shell [[ -t 0 ]] && tput -Txterm setaf 3)
RESET  := $(shell [[ -t 0 ]] && tput -Txterm sgr0)

# Add the following 'help' target to your Makefile
# And add help text after each target name starting with '\#\#'
# A category can be added with @category

HELP_FUN = \
    %help; \
    while(<>) { push @{$$help{$$2 // 'main'}}, [$$1, $$3] if /^([a-zA-Z0-9\-\_\%]+)\s*:.*\#\#(?:@([a-zA-Z0-9\-\_\%]+))?\s(.*)$$/ }; \
    print "usage: make [target]\n\n"; \
    for (sort keys %help) { \
    print "${WHITE}$$_:${RESET}\n"; \
    for (@{$$help{$$_}}) { \
    $$sep = " " x (60 - length $$_->[0]); \
    print "  ${YELLOW}$$_->[0]${RESET}$$sep${GREEN}$$_->[1]${RESET}\n"; \
    }; \
    print "\n"; }

help:  ##@other Show this help.
	@perl -e '$(HELP_FUN)' $(MAKEFILE_LIST)

#
## terraform targets
#
terraform-init-upgrade: check-vars
	@terraform -chdir=${TF_DIR} init -upgrade
terraform-init-migrate-state: check-vars
	@terraform -chdir=${TF_DIR} init -migrate-state
terraform-init: check-vars
	@terraform -chdir=${TF_DIR} init

terraform-workspace: check-vars
	@echo hello

terraform-plan: check-vars ##@terraform generate terraform plan
	@echo Running...
	@terraform -chdir=${TF_DIR} plan -input=false -out terraform.tfplan
terraform-plan-target: check-vars
	@echo Running...
	@terraform -chdir=${TF_DIR} plan -input=false -target $(TAR) -out terraform.tfplan

terraform-apply: check-vars ##@terraform generate terraform plan
	@echo Running...
	@terraform -chdir=${TF_DIR} apply -input=false terraform.tfplan

terraform-apply-refresh-only: check-vars ##@terraform generate terraform plan
	@echo Running...
	@terraform -chdir=${TF_DIR} apply -refresh-only -input=false

terraform-fmt:  ##@terraform format terraform configuration
	@terraform fmt -recursive -diff

terraform-state-pull:  ##@terraform generate terraform plan
	@echo Running...
	@terraform -chdir=${TF_DIR} state pull > ${TF_DIR}/terraform.tfstate

terraform-bootstrap: terraform-init terraform-workspace set-bootstrap-vars  ##@terraform bootstrap terraform backend
	@terraform -chdir=${TF_DIR} apply -input=false -auto-approve 

terraform-destroy: terraform-workspace set-bootstrap-vars  ##@terraform destroy terraform backend
	@terraform -chdir=${TF_DIR} destroy -input=false -auto-approve -lock=false

#
## helpers
#

check-vars:
	@[ "${AWS_ACCESS_KEY_ID}" ] || ( echo "[ERROR]: AWS_ACCESS_KEY_ID variable is not set"; exit 1 )
	@[ "${AWS_SECRET_ACCESS_KEY}" ] || ( echo "[ERROR]: AWS_SECRET_ACCESS_KEY variable is not set"; exit 1 )
	@[ "${CLOUDFLARE_API_KEY}" ] || ( echo "[ERROR]: CLOUDFLARE_API_KEY variable is not set"; exit 1 )
	@[ "${CLOUDFLARE_EMAIL}" ] || ( echo "[ERROR]: CLOUDFLARE_EMAIL variable is not set"; exit 1 )

set-tf-backend-vars:
	@echo set tf backend vars

set-bootstrap-vars: set-tf-backend-vars
	@echo set tf bootstrap vars

print-vars:
	@echo "Environment variables"
	@echo "----------------------------------"
	@IFS=' ' read -r -a env_vars <<< "${ENV_VARS}"; \
	for var in "$${env_vars[@]}"; do \
		echo "$${var}=$${!var}"; \
	done
