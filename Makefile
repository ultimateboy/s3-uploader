default: docker_build

DOCKER_IMAGE ?= quay.io/lachie83/s3-uploader
BUILD_NUMBER ?= `git rev-parse --short HEAD`
VCS_REF ?= `git rev-parse --short HEAD`

.PHONY: docker_build
docker_build:
	@docker build \
	  --build-arg VCS_REF=$(VCS_REF) \
	  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
	  -t $(DOCKER_IMAGE):$(BUILD_NUMBER) .

.PHONY: docker_push
docker_push:
	# Push to DockerHub
	docker tag $(DOCKER_IMAGE):$(BUILD_NUMBER) $(DOCKER_IMAGE):latest
	docker push $(DOCKER_IMAGE):$(BUILD_NUMBER)
	docker push $(DOCKER_IMAGE):latest

# go option
GO        ?= go
PKG       := $(shell glide novendor)
TAGS      :=
TESTS     := .
TESTFLAGS :=
LDFLAGS   :=
GOFLAGS   :=
BINDIR    := $(CURDIR)/bin

.PHONY: all
all: build

.PHONY: build
build:
	GOBIN=$(BINDIR) $(GO) install $(GOFLAGS) -tags '$(TAGS)' -ldflags '$(LDFLAGS)' github.com/lachie83/s3-uploader/...

HAS_GLIDE := $(shell command -v glide;)
HAS_GIT := $(shell command -v git;)

.PHONY: bootstrap
bootstrap:
ifndef HAS_GLIDE
	go get -u github.com/Masterminds/glide
endif
ifndef HAS_GIT
	$(error You must install Git)
endif
	glide install
