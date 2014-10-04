IMAGE_TAG := gbleux/haraka
IMAGE_NAME := gbleux-haraka
EXAMPLE_TAG := haraka-example

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
		$(IMAGE_TAG)

run-example: $(VOLATILE_DIR)/data $(VOLATILE_DIR)/logs
	$(DOCKER) run \
		--rm \
		--publish="1025:25" \
		--volume="$(VOLATILE_DIR)/data:/data" \
		--volume="$(VOLATILE_DIR)/logs:/logs" \
		$(EXAMPLE_TAG)

run-shell:
	$(DOCKER) run \
		--rm \
		--tty \
		--interactive \
		--entrypoint /bin/sh \
		$(IMAGE_TAG) -l

send-mail:
	$(SWAKS) --to haraka@example.com \
		--server localhost:1025

clean:
	rm -r $(VOLATILE_DIR)

$(VOLATILE_DIR)/data:
	mkdir -p $@ && chmod 0777 $@

$(VOLATILE_DIR)/logs:
	mkdir -p $@ && chmod 0777 $@

.PHONY: clean send-mail
.PHONY: build build-example
.PHONY: run run-shell run-example