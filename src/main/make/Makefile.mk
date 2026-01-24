#
# Makefile.mk
#
# Parameters:
#
# - GAIA_BUILD_TYPE
#     The build type: `debug` or `release`
# - GAIA_CXX_TOOLCHAIN
#     The C++ toolchain: `gnu` or `llvm`
# - JOBS
#     Number of jobs for GNU Make (0: none, N: N jobs, default: 2/3 nproc)
# - TEST
#     Run tests matching the pattern
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

export BUILD_DIR := build/$(GAIA_BUILD_TYPE)
PROJECT_NAME := $(notdir $(CURDIR))

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

# Select compiler -------------------------------------------------------------------------------------------

ifeq ($(GAIA_CXX_TOOLCHAIN),llvm)
  export CC := clang
  export CXX := clang++
endif

# CMake -----------------------------------------------------------------------------------------------------

CMAKE_PRESET := linux-$(GAIA_BUILD_TYPE)

CMAKE_TRAILING_FLAGS :=
ifneq ($(VERBOSE),)
  CMAKE_TRAILING_FLAGS += -v
endif

CTEST_FLAGS := --output-on-failure
ifneq ($(TEST),)
  CTEST_FLAGS += -R $(TEST)
endif
ifneq ($(VERBOSE),)
  CTEST_FLAGS += -V
endif

# Cppcheck --------------------------------------------------------------------------------------------------

CPPCHECK_COMPILE_COMMANDS_JSON := $(BUILD_DIR)/cppcheck/compile_commands.json

CPPCHECK_FLAGS := \
    --check-level=exhaustive \
    --cppcheck-build-dir=$(BUILD_DIR)/cppcheck  \
    --enable=all \
    --error-exitcode=1 \
    --inline-suppr \
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

# Doxygen ---------------------------------------------------------------------------------------------------

DOXYGEN_FLAGS :=
ifeq ($(VERBOSE),)
  DOXYGEN_FLAGS += -q
endif

# GNU Make --------------------------------------------------------------------------------------------------

GMAKE_FLAGS := --no-print-directory
ifneq ($(JOBS),)
  ifneq ($(JOBS),0)
    GMAKE_FLAGS += -j$(JOBS)
  endif
else
  GMAKE_FLAGS += -j$(GAIA_NPROC_2_3) -l$(GAIA_NPROC)
endif

# Predefined targets ----------------------------------------------------------------------------------------

CMAKE_DEPS := $(shell find -name CMakeLists.txt) $(shell find cmake -name "*.cmake")

$(BUILD_DIR)/Makefile: $(CMAKE_DEPS)
	@$(call print-info,$@)
	@cmake $(CMAKE_FLAGS) --preset $(CMAKE_PRESET)

.PHONY: cmake-build
cmake-build: $(BUILD_DIR)/Makefile
	@$(call print-info,$@)
	@cmake $(CMAKE_FLAGS) --build --preset $(CMAKE_PRESET) $(CMAKE_TRAILING_FLAGS) -- $(GMAKE_FLAGS)

.PHONY: cmake-test
cmake-test: cmake-build
	@$(call print-info,$@)
	@ctest $(CTEST_FLAGS) --preset $(CMAKE_PRESET)

$(BUILD_DIR)/compile_commands.json: cmake-build

compile_commands.json: $(BUILD_DIR)/compile_commands.json
	@echo ">" $@
	@filter-compile-commands.py -o $@ $< $(PROJECT_NAME)/src

.PHONY: check
check: compile_commands.json
	@$(call print-info,$@)
	@mkdir -p $(BUILD_DIR)/cppcheck
	@cppcheck $(CPPCHECK_FLAGS) --project=compile_commands.json

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
