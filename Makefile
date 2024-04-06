# BuildKit enables higher performance docker builds and caching possibility
# to decrease build times and increase productivity for free.
# https://docs.docker.com/compose/environment-variables/envvars/
export DOCKER_BUILDKIT ?= 1
export COMPOSE_DOCKER_CLI_BUILD ?= 1

IMAGE_NAMESPACE ?= wayofdev/php-dev
IMAGE_TEMPLATE ?= 8.2-fpm-alpine
IMAGE_TAG ?= $(IMAGE_NAMESPACE):$(IMAGE_TEMPLATE)-latest

DOCKERFILE_DIR ?= ./dist/dev/$(IMAGE_TEMPLATE)
CACHE_FROM ?= $(IMAGE_TAG)
OS ?= $(shell uname)
CURRENT_DIR ?= $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

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
MAKE_LOGFILE = /tmp/docker-php-dev.log
MAKE_CMD_COLOR := $(BLUE)

default: all

help:
	@echo 'Management commands for package:'
	@echo 'Usage:'
	@echo '    ${MAKE_CMD_COLOR}make${RST}                       Builds default image and then runs dgoss tests'
	@grep -E '^[a-zA-Z_0-9%-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "    ${MAKE_CMD_COLOR}make %-21s${RST} %s\n", $$1, $$2}'
	@echo
	@echo '    📑 Logs are stored in      $(MAKE_LOGFILE)'
	@echo
	@echo '    📦 Package                 docker-php-dev (github.com/wayofdev/docker-php-dev)'
	@echo '    🤠 Author                  Andrij Orlenko (github.com/lotyp)'
	@echo '    🏢 ${YELLOW}Org                     wayofdev (github.com/wayofdev)${RST}'
.PHONY: help

.EXPORT_ALL_VARIABLES:

# Default action
# Defines default command when `make` is executed without additional parameters
# ------------------------------------------------------------------------------------
all: generate build test
PHONY: all


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

test: ## Run dgoss tests over docker images
	set -eux
	GOSS_FILES_STRATEGY=cp GOSS_FILES_PATH=$(DOCKERFILE_DIR) dgoss run -t $(IMAGE_TAG)
.PHONY: test

pull: ## Pulls docker image from upstream
	docker pull $(IMAGE_TAG)
.PHONY: pull

push: ## Pushes image to upstream
	docker push $(IMAGE_TAG)
.PHONY: push

ssh: ## Login into built image
	docker run --rm -it -v $(PWD)/:/opt/docker-php-dev $(IMAGE_TAG) sh
.PHONY: ssh


# Ansible Actions
# ------------------------------------------------------------------------------------
generate: ## Generates dockerfiles from ansible templates
	ansible-playbook src/playbook.yml
PHONY: generate

clean: ## Cleans up generated files
	rm -rf ./dist/*
PHONY: clean


# Code Quality, Git, Linting, Testing
# ------------------------------------------------------------------------------------
hooks: ## Install git hooks from pre-commit-config
	pre-commit install
	pre-commit autoupdate
.PHONY: hooks

lint-yaml: ## Lints yaml files inside project
	yamllint .
.PHONY: lint-yaml

lint-ansible: ## Lint ansible files inside project
	ansible-lint .
.PHONY: lint-ansible

lint-docker: ## Run hadolint linter over dist Dockerfiles
	hadolint -V ./dist/dev/7.4-cli-alpine/Dockerfile
	hadolint -V ./dist/dev/7.4-fpm-alpine/Dockerfile
	hadolint -V ./dist/dev/7.4-fpm-supervisord/Dockerfile
	hadolint -V ./dist/dev/8.0-cli-alpine/Dockerfile
	hadolint -V ./dist/dev/8.0-fpm-alpine/Dockerfile
	hadolint -V ./dist/dev/8.0-fpm-supervisord/Dockerfile
	hadolint -V ./dist/dev/8.1-cli-alpine/Dockerfile
	hadolint -V ./dist/dev/8.1-fpm-alpine/Dockerfile
	hadolint -V ./dist/dev/8.1-fpm-supervisord/Dockerfile
	hadolint -V ./dist/dev/8.2-cli-alpine/Dockerfile
	hadolint -V ./dist/dev/8.2-fpm-alpine/Dockerfile
	hadolint -V ./dist/dev/8.2-fpm-supervisord/Dockerfile
	hadolint -V ./dist/dev/8.3-cli-alpine/Dockerfile
	hadolint -V ./dist/dev/8.3-fpm-alpine/Dockerfile
	hadolint -V ./dist/dev/8.3-fpm-supervisord/Dockerfile
.PHONY: lint-docker
