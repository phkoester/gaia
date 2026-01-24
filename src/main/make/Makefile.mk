#
# Makefile.mk
#
# Parameters:
#
# - VERBOSE
#     Produce verbose output
#

# Check prerequisites ---------------------------------------------------------------------------------------

ifeq ($(GAIA_VERSION),)
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

# Variables -------------------------------------------------------------------------------------------------

BUILD_DEPS :=
TEST_DEPS :=

# Some functions --------------------------------------------------------------------------------------------

lower = $(shell echo $1 | tr A-Z -az)

# $1: items to move to the back
# $2: all items
move-back = $(filter-out $1,$2) $1

# $1: items to move to the front
# $2: all items
move-front = $1 $(filter-out $1,$2)

# $1: target
define print-info
$(info ####################)
$(info #)
$(info # $(notdir $(realpath .)): $1 ($(GAIA_CXX_TOOLCHAIN), $(GAIA_BUILD_TYPE)))
$(info #)
$(info ####################)

endef

# $1: directory
print-version = $(shell python3 -c 'import gaia; gaia.print_version("$1")')

unique = $(if $1,$(firstword $1) $(call unique,$(filter-out $(firstword $1),$1)))

upper = $(shell echo $1 | tr a-z A-Z)

# $1: path
# $2: version name
# $3: version
write-version-header = $(shell python3 -c 'import gaia; gaia.write_version_header("$1", "$2", "$3")')

# Doxygen ---------------------------------------------------------------------------------------------------

DOXYGEN_FLAGS :=
ifeq ($(VERBOSE),)
  DOXYGEN_FLAGS += -q
endif

# Cppcheck --------------------------------------------------------------------------------------------------

CPPCHECK_FLAGS := \
    $(CXX_DEFINES) \
    --check-level=exhaustive \
    --cppcheck-build-dir=$(BUILD_DIR)/cppcheck  \
    --enable=all \
    --error-exitcode=1 \
    --inline-suppr \
    --project=compile_commands.json \
    --suppress=missingIncludeSystem \
    --suppress=shadowFunction \
    --suppress=syntaxError \
    --suppress=unknownMacro \
    --suppress=unmatchedSuppression \
    --suppress=unusedFunction

ifeq ($(VERBOSE),)
  CPPCHECK_FLAGS += --quiet --suppress=checkersReport
else
  CPPCHECK_FLAGS += --verbose
endif

.PHONY: check
check: compile_commands.json
	@$(call print-info,$@)
	@mkdir -p $(BUILD_DIR)/cppcheck
	@cppcheck $(CPPCHECK_FLAGS)

# Predefined targets ----------------------------------------------------------------------------------------

.PHONY: info
info:
	@$(call print-info,$@)
	@echo
	@echo "Host           : $(GAIA_HOST)"
	@echo "Target         : $(GAIA_TARGET)"
	@echo "C++ toolchain  : $(GAIA_CXX_TOOLCHAIN)"
	@echo "Build type     : $(GAIA_BUILD_TYPE)"
	@echo
	@echo Current Gaia settings:
	@printenv | grep ^GAIA_ | grep -v ^GAIA_COLOR | sort | sed 's/^/  /'

# EOF
