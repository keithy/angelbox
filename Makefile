SHELL := /bin/bash

GITHUB_USER ?= joeblackwaslike
GITHUB_ORG ?= joeblackwaslike
GITHUB_REPO := docker-dcgoss
GITHUB_TAG = $(shell git tag | sort -n | tail -1)

DOCKER_USER ?= joeblackwaslike
DOCKER_ORG ?= joeblackwaslike
DOCKER_REPO := dcgoss
DOCKER_TAG := latest
DOCKER_IMAGE := $(DOCKER_ORG)/$(DOCKER_REPO):$(DOCKER_TAG)

.PHONY: all build build-test templates test push-image

all: build test

build:
	docker build --force-rm -t $(DOCKER_IMAGE) .

build-test:
	tests/edit $(DOCKER_IMAGE) tail -f /dev/null

templates:
	tmpld --strict --data=templates/vars.yaml \
		$(shell find templates -type f -name '*.j2' | xargs)

test:
	tests/run $(DOCKER_IMAGE) tail -f /dev/null

push-image:
	if [[ $$TRAVIS == 'true' ]]; then \
		docker login -u $(DOCKER_USER) -p $(DOCKER_PASS); \
	fi
	docker push $(DOCKER_IMAGE)
