SHELL := /usr/bin/env bash
VERSION ?= 0.0.0-dev
SHELL_FILES := $$(find bin src scripts tests -type f \( -name '*.sh' -o -name '*.bats' -o -path 'bin/multigravity' -o -path 'scripts/*' \))

.PHONY: build lint test reproducible clean release-check

build:
	VERSION=$(VERSION) ./scripts/build

lint: build
	bash -n bin/multigravity scripts/build scripts/install scripts/uninstall dist/multigravity
	find src -type f -name '*.sh' -print0 | xargs -0 -n1 bash -n
	shellcheck -x $(SHELL_FILES) dist/multigravity
	shfmt -d -i 2 -ci bin src scripts tests

test: build
	bats --recursive tests

reproducible:
	rm -rf dist/repro-a dist/repro-b
	mkdir -p dist/repro-a dist/repro-b
	VERSION=$(VERSION) OUTPUT=$$(pwd)/dist/repro-a/multigravity ./scripts/build >/dev/null
	VERSION=$(VERSION) OUTPUT=$$(pwd)/dist/repro-b/multigravity ./scripts/build >/dev/null
	cmp dist/repro-a/multigravity dist/repro-b/multigravity

release-check: lint test reproducible
	[[ "$(VERSION)" =~ ^[0-9]+\.[0-9]+\.[0-9]+$$ ]]

clean:
	rm -rf dist
