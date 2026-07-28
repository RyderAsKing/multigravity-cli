SHELL := /usr/bin/env bash
VERSION ?= 0.0.0-dev
COMMIT ?= $$(git rev-parse --verify HEAD 2>/dev/null || printf unknown)
SHELL_FILES := $$(find bin src scripts tests -type f \( -name '*.sh' -o -name '*.bats' -o -path 'bin/multigravity' -o -path 'scripts/*' \))

.PHONY: build lint test reproducible clean release-check

build:
	VERSION=$(VERSION) COMMIT=$(COMMIT) ./scripts/build

lint: build
	bash -n bin/multigravity scripts/build scripts/install scripts/uninstall scripts/check-release-history dist/multigravity-linux-all
	find src -type f -name '*.sh' -print0 | xargs -0 -n1 bash -n
	shellcheck -x $(SHELL_FILES) dist/multigravity-linux-all
	shfmt -d -i 2 -ci bin src scripts tests

test: build
	bats --recursive tests

reproducible:
	rm -rf dist/repro-a dist/repro-b
	mkdir -p dist/repro-a dist/repro-b
	VERSION=$(VERSION) COMMIT=$(COMMIT) OUTPUT=$$(pwd)/dist/repro-a/multigravity-linux-all ./scripts/build >/dev/null
	VERSION=$(VERSION) COMMIT=$(COMMIT) OUTPUT=$$(pwd)/dist/repro-b/multigravity-linux-all ./scripts/build >/dev/null
	cmp dist/repro-a/multigravity-linux-all dist/repro-b/multigravity-linux-all

release-check: lint test reproducible
	[[ "$(VERSION)" =~ ^[0-9]+\.[0-9]+\.[0-9]+$$ ]]
	! grep -R -E 'raw\.githubusercontent\.com|/main/|sujitagarwal|PowerShell|Darwin|Windows' --exclude-dir=.git --exclude-dir=.opencode --exclude=NOTICE.md --exclude=Makefile --exclude=ci.yml .
	./scripts/check-release-history

clean:
	rm -rf dist
