DOCKER_REPO ?= gbleux

IMAGE_TAG := $(DOCKER_REPO)/haraka
IMAGE_NAME := $(DOCKER_REPO)-haraka
EXAMPLE_TAG := haraka-example
EXAMPLE_NAME := haraka-example

VOLATILE_DIR = $(abspath volatile)

DOCKER ?= docker
SWAKS ?= swaks

build:
	$(DOCKER) build \
		--rm \
		-t $(IMAGE_TAG) \
		.

build-example:
	$(DOCKER) build \
		--rm \
		-t $(EXAMPLE_TAG) \
		./example

run:
	$(DOCKER) run \
		--rm \
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
	$(DOCKER) run \
		--rm \
		--tty \
		--interactive \
		--name $(IMAGE_NAME) \
		--entrypoint /bin/sh \
		$(IMAGE_TAG) -l

send-mail:
	$(SWAKS) --to haraka@example.com \
		--server 127.0.0.1:1025

clean:
	rm -r $(VOLATILE_DIR)

$(VOLATILE_DIR)/data:
	mkdir -p $@ && chmod 0777 $@

$(VOLATILE_DIR)/logs:
	mkdir -p $@ && chmod 0777 $@

.PHONY: clean send-mail
.PHONY: build build-example
.PHONY: run run-shell run-example