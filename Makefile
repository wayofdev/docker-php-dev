IMAGE_NAMESPACE ?= wayofdev/php-dev
TEMPLATE ?= 8.0-cli-alpine



########################################################################################################################
# Most likely there is nothing to change behind this line
########################################################################################################################

IMAGE_TAG ?= $(IMAGE_NAMESPACE):$(TEMPLATE)-latest
DOCKERFILE_DIR ?= ./dist/dev/$(TEMPLATE)
CACHE_FROM ?= $(IMAGE_TAG)
OS ?= $(shell uname)
CURRENT_DIR ?= $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

all: build test
PHONY: all

build:
	cd $(CURRENT_DIR)$(DOCKERFILE_DIR); \
	docker build . -t $(IMAGE_TAG)
PHONY: build

build-from-cache:
	cd $(CURRENT_DIR)$(DOCKERFILE_DIR); \
	docker build --cache-from $(CACHE_FROM) . -t $(IMAGE_TAG)
PHONY: build-from-cache

test:
	set -eux
	GOSS_FILES_STRATEGY=cp GOSS_FILES_PATH=$(DOCKERFILE_DIR) dgoss run -t $(IMAGE_TAG)
.PHONY: test

pull:
	docker pull $(IMAGE_TAG)
.PHONY: pull

push:
	docker push $(IMAGE_TAG)
.PHONY: push

ssh:
	docker run --rm -it -v $(PWD)/:/opt/docker-php-core $(IMAGE_TAG) sh
.PHONY: ssh

install-hooks:
	pre-commit install --hook-type commit-msg
.PHONY: install-hooks



########################################################################################################################
# Ansible
########################################################################################################################

generate:
	ansible-playbook src/generate.yml
PHONY: generate

clean:
	rm -rf ./dist/*
PHONY: clean
