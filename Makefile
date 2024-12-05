# BuildKit enables higher performance docker builds and caching possibility
# to decrease build times and increase productivity for free.
# https://docs.docker.com/compose/environment-variables/envvars/
export DOCKER_BUILDKIT ?= 1
export COMPOSE_DOCKER_CLI_BUILD ?= 1

# Docker binary to use, when executing docker tasks
DOCKER ?= docker

IMAGE_NAMESPACE ?= wayofdev/php-dev
IMAGE_TEMPLATE ?= 8.4-cli-alpine
IMAGE_TAG ?= $(IMAGE_NAMESPACE):$(IMAGE_TEMPLATE)-latest

DOCKERFILE_DIR ?= ./dist/dev/$(IMAGE_TEMPLATE)
CACHE_FROM ?= $(IMAGE_TAG)
OS ?= $(shell uname)
CURRENT_DIR ?= $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

YAML_CONFIG_PATH ?= .github/.yamllint.yaml

YAML_LINT_RUNNER ?= $(DOCKER) run --rm $$(tty -s && echo "-it" || echo) \
	-v $(PWD):/data \
	cytopia/yamllint:latest \
	-c $(YAML_CONFIG_PATH) \
	-f colored .

ACTION_LINT_RUNNER ?= $(DOCKER) run --rm $$(tty -s && echo "-it" || echo) \
	-v $(shell pwd):/repo \
	 --workdir /repo \
	 rhysd/actionlint:latest \
	 -color

MARKDOWN_LINT_RUNNER ?= $(DOCKER) run --rm $$(tty -s && echo "-it" || echo) \
	-v $(shell pwd):/app \
	--workdir /app \
	davidanson/markdownlint-cli2-rules:latest \
	--config ".github/.markdownlint.json"

ANSIBLE_LINT_RUNNER ?= $(DOCKER) run --rm $$(tty -s && echo "-it" || echo) \
	-v $(shell pwd):/code \
	-e YAMLLINT_CONFIG_FILE=$(YAML_CONFIG_PATH) \
	--workdir /code \
	pipelinecomponents/ansible-lint:latest \
	ansible-lint --show-relpath --config-file ".github/.ansible-lint.yml"

#
# Self documenting Makefile code
# ------------------------------------------------------------------------------------
ifneq ($(TERM),)
	BLACK := $(shell tput setaf 0)
	RED := $(shell tput setaf 1)
	GREEN := $(shell tput setaf 2)
	YELLOW := $(shell tput setaf 3)
	LIGHTPURPLE := $(shell tput setaf 4)
	PURPLE := $(shell tput setaf 5)
	BLUE := $(shell tput setaf 6)
	WHITE := $(shell tput setaf 7)
	RST := $(shell tput sgr0)
else
	BLACK := ""
	RED := ""
	GREEN := ""
	YELLOW := ""
	LIGHTPURPLE := ""
	PURPLE := ""
	BLUE := ""
	WHITE := ""
	RST := ""
endif
MAKE_LOGFILE = /tmp/wayofdev-docker-php-dev.log
MAKE_CMD_COLOR := $(BLUE)

default: all

help:
	@echo 'Management commands for package:'
	@echo 'Usage:'
	@echo '    ${MAKE_CMD_COLOR}make${RST}                       Builds default image and then runs dgoss tests'
	@grep -E '^[a-zA-Z_0-9%-]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "    ${MAKE_CMD_COLOR}make %-21s${RST} %s\n", $$1, $$2}'
	@echo
	@echo '    📑 Logs are stored in      $(MAKE_LOGFILE)'
	@echo
	@echo '    📦 Package                 docker-php-dev (github.com/wayofdev/docker-php-dev)'
	@echo '    🤠 Author                  the dev (github.com/lotyp)'
	@echo '    🏢 ${YELLOW}Org                     wayofdev (github.com/wayofdev)${RST}'
	@echo
.PHONY: help

.EXPORT_ALL_VARIABLES:

#
# Default action
# Defines default command when `make` is executed without additional parameters
# ------------------------------------------------------------------------------------
all: generate build test
PHONY: all

#
# Docker Actions
# ------------------------------------------------------------------------------------
build: ## Build default docker image
	cd $(CURRENT_DIR)$(DOCKERFILE_DIR); \
	docker build -t $(IMAGE_TAG) .
PHONY: build

analyze: ## Analyze docker image
	cd $(CURRENT_DIR)$(DOCKERFILE_DIR); \
	dive build -t $(IMAGE_TAG) .
.PHONY: analyze

build-from-cache: ## Build default docker image using cached layers
	cd $(CURRENT_DIR)$(DOCKERFILE_DIR); \
	docker build --cache-from $(CACHE_FROM) . -t $(IMAGE_TAG)
PHONY: build-from-cache

pull: ## Pulls docker image from upstream
	docker pull $(IMAGE_TAG)
.PHONY: pull

push: ## Pushes image to upstream
	docker push $(IMAGE_TAG)
.PHONY: push

ssh: ## Login into built image
	docker run --rm -it -v $(PWD)/:/opt/docker-php-dev $(IMAGE_TAG) sh
.PHONY: ssh

#
# Ansible Actions
# ------------------------------------------------------------------------------------
generate: ## Generates dockerfiles from ansible templates
	ansible-playbook src/playbook.yml
PHONY: generate

clean: ## Cleans up generated files
	rm -rf ./dist/*
PHONY: clean

#
# Testing
# ------------------------------------------------------------------------------------
test: ## Run dgoss tests over docker images
	set -eux
	GOSS_SLEEP="0.4" GOSS_WAIT_OPTS="-r 40s -s 2s > /dev/stdout" GOSS_FILES_STRATEGY=cp GOSS_FILES_PATH=$(DOCKERFILE_DIR) dgoss run -t $(IMAGE_TAG)
.PHONY: test

#
# Code Quality, Git, Linting
# ------------------------------------------------------------------------------------
hooks: ## Install git hooks from pre-commit-config
	pre-commit install
	pre-commit install --hook-type commit-msg
	pre-commit autoupdate
.PHONY: hooks

lint: lint-yaml lint-actions lint-md lint-ansible ## Runs all linting commands
.PHONY: lint

lint-yaml: ## Lints yaml files inside project
	@$(YAML_LINT_RUNNER) | tee -a $(MAKE_LOGFILE)
.PHONY: lint-yaml

lint-actions: ## Lint all github actions
	@$(ACTION_LINT_RUNNER) | tee -a $(MAKE_LOGFILE)
.PHONY: lint-actions

lint-md: ## Lint all markdown files using markdownlint-cli2
	@$(MARKDOWN_LINT_RUNNER) --fix "**/*.md" "!CHANGELOG.md" "!app/vendor" "!app/node_modules" | tee -a $(MAKE_LOGFILE)
.PHONY: lint-md

lint-md-dry: ## Lint all markdown files using markdownlint-cli2 in dry-run mode
	@$(MARKDOWN_LINT_RUNNER) "**/*.md" "!CHANGELOG.md" "!app/vendor" "!app/node_modules" | tee -a $(MAKE_LOGFILE)
.PHONY: lint-md-dry

lint-ansible: ## Lint ansible files inside project
	@$(ANSIBLE_LINT_RUNNER) . | tee -a $(MAKE_LOGFILE)
.PHONY: lint-ansible

#
# Release
# ------------------------------------------------------------------------------------
commit: ## Run commitizen to create commit message
	czg commit --config="./.github/.cz.config.js"
.PHONY: commit
