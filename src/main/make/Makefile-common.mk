#
# Makefile-common.mk
#
# Parameters:
#
# - GAIA_BUILD_TYPE
#     The build type: `debug` or `release`
# - GAIA_CXX_TOOLCHAIN
#     The C++ toolchain: `gnu` or `llvm`
# - GAIA_DIR
# - GAIA_VERSION
#
# Targets:
#
# - bench
# - build
# - check
# - clean
# - configure
# - default
# - doc
# - info
# - run
# - test
# - update
# - validate
# - version
#

# Check prerequisites ---------------------------------------------------------------------------------------

ifndef GAIA_DIR
  $(error `GAIA_DIR` not set)
endif
ifndef GAIA_VERSION
  $(error `GAIA_VERSION` not set)
endif

ifeq ($(filter $(GAIA_CXX_TOOLCHAIN),gnu llvm),)
  $(error `GAIA_CXX_TOOLCHAIN`: Invalid value `$(GAIA_CXX_TOOLCHAIN)`; expected `gnu` or `llvm`)
endif

ifeq ($(filter $(GAIA_BUILD_TYPE),debug release),)
  $(error `GAIA_BUILD_TYPE`: Invalid value `$(GAIA_BUILD_TYPE)`; expected `debug` or `release`)
endif

# Constants -------------------------------------------------------------------------------------------------

COMMA := ,
EMPTY :=
SPACE := $(EMPTY) $(EMPTY)

GAIA_DEPS := \
  $(wildcard $(GAIA_DIR)/bin/*) \
  $(wildcard $(GAIA_DIR)/src/main/cmake/*) \
  $(wildcard $(GAIA_DIR)/src/main/make/*)

export PROJECT_NAME := $(notdir $(CURDIR))

# Variables -------------------------------------------------------------------------------------------------

TEST_DEPS :=

# Functions -------------------------------------------------------------------------------------------------

lower = $(shell echo $1 | tr A-Z -az)

# $1: items to move to the back
# $2: all items
move-back = $(filter-out $1,$2) $1

# $1: items to move to the front
# $2: all items
move-front = $1 $(filter-out $1,$2)

# $1: target
define print-target
$(info ########################################)
$(info #)
$(info # $(PROJECT_NAME): $1)
$(info #)
$(info ########################################)
endef

# $1: directory
print-version = $(shell python3 -c 'import gaia; gaia.print_version("$1")')

unique = $(if $1,$(firstword $1) $(call unique,$(filter-out $(firstword $1),$1)))

upper = $(shell echo $1 | tr a-z A-Z)

# $1: path
# $2: version name
# $3: version
write-version-header = $(shell python3 -c 'import gaia; gaia.write_version_header("$1", "$2", "$3")')

# Select C and C++ compilers --------------------------------------------------------------------------------

ifeq ($(GAIA_CXX_TOOLCHAIN),gnu)
  export CC := gcc
  export CXX := g++
endif
ifeq ($(GAIA_CXX_TOOLCHAIN),llvm)
  export CC := clang
  export CXX := clang++
endif

# Phony targets ---------------------------------------------------------------------------------------------

.PHONY: \
  bench \
  build \
  check \
  clean \
  configure \
  default \
  doc \
  info \
  run \
  test \
  update \
  validate \
  version

# Targets ---------------------------------------------------------------------------------------------------

# `default` must be the first target
default: build

bench: build

build: configure

check: build

doc: build

info:
	@$(call print-target,$@)
	@echo "Host         : $(GAIA_HOST)"
	@echo "Target       : $(GAIA_TARGET)"
	@echo "C++ toolchain: $(GAIA_CXX_TOOLCHAIN)"
	@echo "Build type   : $(GAIA_BUILD_TYPE)"
	@echo
	@echo Current Gaia settings:
	@printenv | grep ^GAIA_ | grep -v ^GAIA_COLOR | sort | sed 's/^/  /'

run: build

test: build

update:

validate: build test check doc

version:
	@$(call print-target,$@)
	@echo $(call print-version,.)
	@gaia-git-version

# EOF
