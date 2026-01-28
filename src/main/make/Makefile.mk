#
# Makefile.mk
#
# Parameters:
#
# - COMPILE_DEPS
#     Compile prerequisites
# - GAIA_BUILD_TYPE
#     The build type: `debug` or `release`
# - GAIA_CXX_TOOLCHAIN
#     The C++ toolchain: `gnu` or `llvm`
# - JOBS
#     Number of jobs for GNU Make (0: none, N: N jobs, default: 2/3 nproc)
# - TEST
#     `all` , `test` (default), `bench`, or PATTERN
# - VERBOSE
#     Produce verbose output
#
# Targets that automatically copy files; these are best added to `COMPILE_DEPS` before including this file:
#
# - make.cmd
# - cmake/base.cmake
# - cmake/generate-version.py
#
# CMake targets:
#
# - cmake-configure
#     Configures CMake; this produces a Makefile in the build directory as well as a `compile_commands.json`
#     in the current directory
# - cmake-build
#     Builds the project
# - cmake-test
#     Runs the tests
#
# Other targets:
#
# - check
#     Runs Cppcheck
# - doc
#     Runs Doxygen
#  - info
#     Prints current Gaia configuration
#

# Check prerequisites ---------------------------------------------------------------------------------------

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

export BUILD_DIR := build/$(GAIA_BUILD_TYPE)
export PROJECT_NAME := $(notdir $(CURDIR))

# Variables -------------------------------------------------------------------------------------------------

BUILD_DEPS :=
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

# Configure CMake -------------------------------------------------------------------------------------------

CMAKE_PRESET := linux-$(GAIA_BUILD_TYPE)

CMAKE_TRAILING_FLAGS :=
ifdef VERBOSE
  CMAKE_TRAILING_FLAGS += -v
endif

# Configure CTest -------------------------------------------------------------------------------------------

CTEST_FLAGS := --output-on-failure
ifdef VERBOSE
  CTEST_FLAGS += -V
endif

ifndef TEST
  TEST := test
endif

ifeq ($(TEST),all)
  CTEST_FLAGS += --test-dir $(BUILD_DIR)
else ifeq ($(TEST),test)
  CTEST_FLAGS += --test-dir $(BUILD_DIR)/src/test
else ifeq ($(TEST),bench)
  CTEST_FLAGS += --test-dir $(BUILD_DIR)/src/bench
else
  CTEST_FLAGS += --test-dir $(BUILD_DIR) -R $(TEST)
endif

# Configure Cppcheck ----------------------------------------------------------------------------------------

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

ifndef VERBOSE
  CPPCHECK_FLAGS += --quiet --suppress=checkersReport
else
  CPPCHECK_FLAGS += --verbose
endif

# Configure Doxygen -----------------------------------------------------------------------------------------

DOXYGEN_FLAGS :=
ifndef VERBOSE
  DOXYGEN_FLAGS += -q
endif

# Configure GNU Make ----------------------------------------------------------------------------------------

GMAKE_FLAGS := --no-print-directory
ifdef JOBS
  ifneq ($(JOBS),0)
    GMAKE_FLAGS += -j$(JOBS)
  endif
else
  GMAKE_FLAGS += -j$(GAIA_NPROC_2_3) -l$(GAIA_NPROC)
endif

# Predefined targets ----------------------------------------------------------------------------------------

# Files copied automatically from Gaia ......................................................................
#
# These targets should be added to `COMPILE_DEPS` before including this file.
#
# ...........................................................................................................

make.cmd: $(GAIA_DIR)/src/main/cmd/gaia-make.cmd
	@echo ">" $@
	@cp $< $@

cmake/base.cmake: $(GAIA_DIR)/src/main/cmake/gaia-base.cmake
	@echo ">" $@
	@cp $< $@

cmake/generate-version.py: $(GAIA_DIR)/src/main/cmake/gaia-generate-version.py
	@echo ">" $@
	@cp $< $@

# CMake .....................................................................................................

CMAKE_DEPS := CMakeLists.txt $(shell find src -name CMakeLists.txt) $(shell find cmake -type f)

$(BUILD_DIR)/compile_commands.json: $(COMPILE_DEPS) $(CMAKE_DEPS)
	@$(call print-info,$@)
	@cmake $(CMAKE_FLAGS) --preset $(CMAKE_PRESET)

compile_commands.json: $(BUILD_DIR)/compile_commands.json
	@echo ">" $@
	@filter-compile-commands.py --field file -i $< -o $@ $(PROJECT_NAME)/src

.PHONY: cmake-configure
cmake-configure: compile_commands.json

# Parameters:
#  - TARGET
.PHONY: cmake-build
cmake-build: cmake-configure
	@$(call print-info,$@)
	@cmake $(CMAKE_FLAGS) \
	  --build --preset $(CMAKE_PRESET) \
	  $(if $(TARGET),--target $(TARGET),) \
	  $(CMAKE_TRAILING_FLAGS) \
	  -- $(GMAKE_FLAGS)

.PHONY: cmake-test
cmake-test: cmake-build
	@$(call print-info,$@)
	@ctest $(CTEST_FLAGS)

# `check` ...................................................................................................

.PHONY: check
check: compile_commands.json
	@$(call print-info,$@)
	@mkdir -p $(BUILD_DIR)/cppcheck
	@cppcheck $(CPPCHECK_FLAGS) --project=compile_commands.json

# `doc` .....................................................................................................

.PHONY: doc
doc:
	@$(call print-info,$@)
ifneq ($(wildcard src/main/Doxyfile),)
	@mkdir -p $(BUILD_DIR)/src/main/doc
	@doxygen $(DOXYGEN_FLAGS) src/main/Doxyfile
endif
ifneq ($(wildcard src/test/Doxyfile),)
	@mkdir -p $(BUILD_DIR)/src/test/doc
	@doxygen $(DOXYGEN_FLAGS) src/test/Doxyfile
endif

# `info` ....................................................................................................

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
