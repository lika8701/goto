BUILD_VERSION=v0.3.0
NO_DEBUG_FLAGS=-s -w
LD_FLAGS = -ldflags="$(NO_DEBUG_FLAGS) -X main.buildVersion=$(BUILD_VERSION) -X main.buildDate=$(shell date +%Y-%m-%d) -X main.buildCommit=$(shell git rev-parse --short=8 HEAD)"

## help: print this help message
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'

## lint: run linter
.PHONY: lint
lint:
	@echo 'Running linter'
	@golangci-lint run

## audit: tidy dependencies and format, vet and test all code
.PHONY: audit
audit:
	@echo 'Tidying and verifying module dependencies...'
	go mod tidy
	go mod verify
	@echo 'Formatting code...'
	gofumpt -l -w ./..
	goimports -w -local github.com/grafviktor/goto .
	@echo 'Vetting code...'
	go vet ./...
	staticcheck ./...
	@echo 'Linting code...'
	golangci-lint run
	@$(MAKE) test

## test: run unit tests
.PHONY: test
test:
	@echo 'Running unit tests'
	go test -race -vet=off -count=1 -coverprofile unit.txt -covermode atomic ./...

## unit-test-report: display unit coverage report in html format
.PHONY: unit-test-report
unit-test-report:
	@echo 'The report will be opened in the browser'
	go tool cover -html unit.txt

## run: delete logs and run debug
.PHONY: run
run:
	@echo 'Running debug build'
	@-rm debug.log 2>/dev/null
	go run cmd/goto/*

## build: create binaries for all supported platforms in ./build folder. Archive all binaries with zip.
.PHONY: build
build:
	@-rm -r ./build/*
	@echo 'Creating binary files'
	GOOS=darwin  GOARCH=amd64 go build $(LD_FLAGS) -o ./build/gg-mac     ./cmd/goto/*.go
	GOOS=linux   GOARCH=amd64 go build $(LD_FLAGS) -o ./build/gg-lin     ./cmd/goto/*.go
	GOOS=windows GOARCH=amd64 go build $(LD_FLAGS) -o ./build/gg-win.exe ./cmd/goto/*.go
	@mkdir ./build/goto-$(BUILD_VERSION)/
	@cp ./build/gg* ./build/goto-$(BUILD_VERSION)
	@cd ./build && zip -r goto-$(BUILD_VERSION).zip goto-$(BUILD_VERSION)
	@rm -r ./build/goto-$(BUILD_VERSION)

## build-quick: create binary in ./build folder for your current platform
.PHONY: build-quick
build-quick:
	go build $(LD_FLAGS) -o ./build/gg ./cmd/goto/*.go
	@echo 'Creating build'