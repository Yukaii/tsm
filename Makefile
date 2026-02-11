SHELL := /usr/bin/env bash

.PHONY: build lint test test-integration release-dist clean

build:
	./scripts/build.sh ./tsm

lint:
	./scripts/build.sh ./tsm
	bash -n ./tsm

test: build test-integration

test-integration: build
	./tests/integration/run.sh

release-dist: build
	@if [ -z "$(VERSION)" ]; then \
		echo "Usage: make release-dist VERSION=vX.Y.Z"; \
		exit 1; \
	fi
	./scripts/release-dist.sh $(VERSION)

clean:
	rm -rf ./dist ./tsm
