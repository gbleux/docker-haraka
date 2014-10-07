DOCKER_REPO ?= gbleux

IMAGE_TAG := $(DOCKER_REPO)/haraka
IMAGE_NAME := $(DOCKER_REPO)-haraka
EXAMPLE_TAG := haraka-example
EXAMPLE_NAME := haraka-example

VOLATILE_DIR = $(abspath volatile)

DOCKER ?= docker
SWAKS ?= swaks
RM_R ?= rm -r
MKDIR_P ?= mkdir -p
CHMOD ?= chmod

SHELL ?= /bin/sh
CONTAINER_SHELL ?= $(SHELL)

build:
	$(DOCKER) build \
		--rm \
		-t $(IMAGE_TAG) \
		.

build-onbuild:
	$(DOCKER) build \
		--rm \
		-t $(IMAGE_TAG):onbuild \
		./onbuild

build-example:
	$(DOCKER) build \
		--rm \
		-t $(EXAMPLE_TAG) \
		./example

run: $(VOLATILE_DIR)/data $(VOLATILE_DIR)/logs
	$(DOCKER) run \
		--detach \
		--name $(IMAGE_NAME) \
		$(IMAGE_TAG)

run-example: $(VOLATILE_DIR)/data $(VOLATILE_DIR)/logs
	$(DOCKER) run \
		--rm \
		--name $(EXAMPLE_NAME) \
		--publish="127.0.0.1:1025:25" \
		--volume="$(VOLATILE_DIR)/data:/data" \
		--volume="$(VOLATILE_DIR)/logs:/logs" \
		$(EXAMPLE_TAG)

run-shell:
	-$(DOCKER) run \
		--rm \
		--tty \
		--interactive \
		--entrypoint $(CONTAINER_SHELL) \
		$(IMAGE_TAG) -l

stop:
	$(DOCKER) stop \
		$(IMAGE_NAME)

stop-example:
	$(DOCKER) stop \
		$(EXAMPLE_NAME)

send-mail:
	$(SWAKS) --to haraka@example.com \
		--server 127.0.0.1:1025

clean:
	$(RM_R) $(VOLATILE_DIR)

clean-containers:
	-$(DOCKER) rm --force $(IMAGE_NAME)
	-$(DOCKER) rm --force $(EXAMPLE_NAME)

$(VOLATILE_DIR)/data:
	-$(MKDIR_P) $@
	$(CHMOD) 0777 $@

$(VOLATILE_DIR)/logs:
	-$(MKDIR_P) $@
	$(CHMOD) 0777 $@

.PHONY: clean clean-containers send-mail
.PHONY: build build-onbuild build-example
.PHONY: run run-shell run-example
.PHONY: stop stop-example