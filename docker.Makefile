DOCKER_REGISTRY          ?= docker.io
DOCKER_ORG               ?= $(shell docker info 2>/dev/null | sed '/Username:/!d;s/.* //')
DOCKER_IMAGE             ?= pytorch
DOCKER_FULL_NAME          = $(DOCKER_REGISTRY)/$(DOCKER_ORG)/$(DOCKER_IMAGE)
USER											= $(shell whoami)
UID												= $(shell id -u)
GID												= $(shell id -g)

ifeq ("$(DOCKER_ORG)","")
$(warning WARNING: No docker user found using results from whoami)
DOCKER_ORG                = $(USER)
endif

MULTIPY_COMMIT						= $(shell cat .github/ci_commit_pins/multipy.txt)

CUDA_VERSION              = 11.7.0
CUDNN_VERSION             = 8
BASE_DEVEL                = nvidia/cuda:$(CUDA_VERSION)-cudnn$(CUDNN_VERSION)-devel-ubuntu18.04

# The conda channel to use to install cudatoolkit
CUDA_CHANNEL              = nvidia
# The conda channel to use to install pytorch / torchvision
INSTALL_CHANNEL          ?= pytorch

PYTHON_VERSION           ?= 3.10
PYTORCH_VERSION          ?= $(shell git describe --tags --always)
# Can be either official / dev
BUILD_TYPE               ?= dev
BUILD_PROGRESS           ?= auto
# Intentionally left blank
TRITON_VERSION           ?=
BUILD_ARGS                = --build-arg BASE_IMAGE=$(BASE_IMAGE) \
							--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
							--build-arg CUDA_VERSION=$(CUDA_VERSION) \
							--build-arg CUDA_CHANNEL=$(CUDA_CHANNEL) \
							--build-arg PYTORCH_VERSION=$(PYTORCH_VERSION) \
							--build-arg INSTALL_CHANNEL=$(INSTALL_CHANNEL) \
							--build-arg TRITON_VERSION=$(TRITON_VERSION) \
							--build-arg USER=$(USER) \
							--build-arg UID=$(UID) \
							--build-arg GID=$(GID)
EXTRA_DOCKER_BUILD_FLAGS ?=

BUILD                    ?= build
# Intentionally left blank
PLATFORMS_FLAG           ?=
PUSH_FLAG                ?=
USE_BUILDX               ?=
BUILD_PLATFORMS          ?=
WITH_PUSH                ?= false
# Setup buildx flags
ifneq ("$(USE_BUILDX)","")
BUILD                     = buildx build
ifneq ("$(BUILD_PLATFORMS)","")
PLATFORMS_FLAG            = --platform="$(BUILD_PLATFORMS)"
endif
# Only set platforms flags if using buildx
ifeq ("$(WITH_PUSH)","true")
PUSH_FLAG                 = --push
endif
endif

DOCKER_BUILD              = DOCKER_BUILDKIT=1 \
							docker $(BUILD) \
								--progress=$(BUILD_PROGRESS) \
								$(EXTRA_DOCKER_BUILD_FLAGS) \
								$(PLATFORMS_FLAG) \
								$(PUSH_FLAG) \
								--target $(BUILD_TYPE) \
								$(BUILD_ARGS) .

.PHONY: all
all: devel-image

.PHONY: devel-image
devel-image: BASE_IMAGE := $(BASE_DEVEL)
devel-image: DOCKER_TAG := $(PYTORCH_VERSION)-devel
devel-image:
	$(DOCKER_BUILD)

.PHONY: clean
clean:
	-docker rmi -f $(shell docker images -q $(DOCKER_FULL_NAME))
