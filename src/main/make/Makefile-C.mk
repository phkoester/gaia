# Makefile-C.mk
#
# Parameters:
#
# - ARGS
#     Arguments to pass to the run target
# - CONFIGURE_DEPS
#     Targets to make before configuring
# - DEFAULT_RUN_TARGET
#     The default target to run
# - GAIA_BUILD_CONFIG
#     Overrules GAIA_BUILD_TYPE. If set, uses a multi-configuration generator
# - GAIA_BUILD_TYPE
#     The build type: `debug` or `release`
# - GAIA_CXX_TOOLCHAIN
#     The C++ toolchain: `gnu`, `llvm`, or `msvc`
# - GAIA_DIR
# - MEMCHECK
#     If set to 1, run executables with a memory checker (valgrind on Linux, leaks on macOS)
# - PATTERN
#     - Run only benchmarks or tests matching PATTERN
#     - Check only source files matching PATTERN
# - TARGET
#     The target to build or run
# - VERBOSE
#     If set to 1, produce verbose output
#
# CMake parameters:
#
# - CMAKE_C_COMPILER_LAUNCHER
#     May be set to `ccache`
# - CMAKE_CXX_COMPILER_LAUNCHER
#     May be set to `ccache`
#
# Targets (parameters):
#
# - bench (GAIA_BUILD_*, PATTERN)
# - build (GAIA_BUILD_*, TARGET, VERBOSE)
# - check (GAIA_BUILD_*)
# - clean
# - configure (GAIA_BUILD_*)
# - doc (GAIA_BUILD_*, VERBOSE)
# - rebuild (GAIA_BUILD_*, TARGET, VERBOSE)
# - reconfigure (GAIA_BUILD_*)
# - run (ARGS, DEFAULT_RUN_TARGET, GAIA_BUILD_*, MEMCHECK, TARGET, VERBOSE)
# - test (GAIA_BUILD_*, PATTERN, VERBOSE)

ifndef GAIA_DIR
  $(error `GAIA_DIR` not set)
endif
include $(GAIA_DIR)/src/main/make/Makefile-common.mk

# Single-config or multi-config build? ----------------------------------------------------------------------

ifdef GAIA_BUILD_CONFIG
  # Multi-config build
  export BUILD_DIR := build
  CONFIGURE_PRESET := multi
  BUILD_PRESET := multi-$(GAIA_BUILD_CONFIG)
  TEST_PRESET := multi-$(GAIA_BUILD_CONFIG)

  # Extract configurations from `CMakePresets.json`
  CONFIGS := $(call print-configurations,.,$(CONFIGURE_PRESET))
  ifeq ($(CONFIGS),)
    $(error found no `CMAKE_CONFIGURATION_TYPES` for preset `$(CONFIGURE_PRESET)` in `CMakePresets.json`)
  endif
else
  # Single-config build
  export BUILD_DIR := build-$(GAIA_BUILD_TYPE)
  CONFIGURE_PRESET := $(GAIA_BUILD_TYPE)
  BUILD_PRESET := $(GAIA_BUILD_TYPE)
  TEST_PRESET := $(GAIA_BUILD_TYPE)
endif

# Export these variables so they are usable in Doxyfiles and elsewhere
export BIN_DIR := $(BUILD_DIR)/src/bin$(GAIA_BUILD_CONFIG:%=/%)
export BENCH_DIR := $(BUILD_DIR)/src/bench$(GAIA_BUILD_CONFIG:%=/%)
export EXPERIMENTAL_DIR := $(BUILD_DIR)/src/experimental$(GAIA_BUILD_CONFIG:%=/%)
export MAIN_DIR := $(BUILD_DIR)/src/main$(GAIA_BUILD_CONFIG:%=/%)
export TEST_DIR := $(BUILD_DIR)/src/test$(GAIA_BUILD_CONFIG:%=/%)

CHECK_REPORT_FILE := $(BUILD_DIR)/check-report$(GAIA_BUILD_CONFIG:%=-%).txt

# Constants -------------------------------------------------------------------------------------------------

EXECUTABLE_SUFFIX :=
ifdef GAIA_OS_WINDOWS
  EXECUTABLE_SUFFIX := .exe
endif

CMAKE_DEPS := CMakeLists.txt $(shell find src -name CMakeLists.txt) $(wildcard cmake/*)

ifeq ($(filter $(MAKECMDGOALS),run),run)
  ifeq ($(TARGET),)
    ifeq ($(DEFAULT_RUN_TARGET),)
      $(error `DEFAULT_RUN_TARGET` not set)
    else
      TARGET := $(DEFAULT_RUN_TARGET)
    endif
  endif
endif

# Recursively expanded, so the search runs when the `run` recipe is expanded, i.e., after the prerequisites
# of `run` have been made. Before that, the executable and its directory may not exist yet. Without any
# existing directory, `find` would search `.`, so it is not run then.
RUN_DIRS = $(wildcard $(BIN_DIR) $(BENCH_DIR) $(EXPERIMENTAL_DIR) $(TEST_DIR))
RUN_EXECUTABLE = $(or \
  $(if $(RUN_DIRS),$(shell find $(RUN_DIRS) -executable -name '$(TARGET)$(EXECUTABLE_SUFFIX)' -type f)),\
  $(error found no executable for target `$(TARGET)`))

# Select C and C++ compilers --------------------------------------------------------------------------------

ifeq ($(GAIA_CXX_TOOLCHAIN),gnu)
  # GNU
  ifdef GAIA_OS_MACOS
    # GNU, macOS
    export CC := gcc-16
    export CXX := g++-16
  else
    # GNU, not macOS
    export CC := gcc
    export CXX := g++
  endif
endif
ifeq ($(GAIA_CXX_TOOLCHAIN),llvm)
  # LLVM
  ifdef GAIA_OS_WINDOWS
    # LLVM, Windows: Ninja doesn’t support toolsets like `-T ClangCL`, so select the MSVC-compatible driver
    # directly
    export CC := clang-cl
    export CXX := clang-cl
  else
    # LLVM, not Windows
    export CC := clang
    export CXX := clang++
  endif
endif

# Configure CMake -------------------------------------------------------------------------------------------

CMAKE_CONFIGURE_FLAGS :=

CMAKE_TRAILING_FLAGS :=

ifeq ($(VERBOSE),1)
  CMAKE_TRAILING_FLAGS += -v
endif

CMAKE_FLAGS :=

# Configure CTest -------------------------------------------------------------------------------------------

CTEST_FLAGS := --output-on-failure
ifeq ($(VERBOSE),1)
  CTEST_FLAGS += -V
endif

# `filter-compile-commands` ---------------------------------------------------------------------------------

FILTER_COMPILE_COMMANDS_FLAGS := --field 'file:$(PROJECT_NAME)/src/'
ifdef GAIA_BUILD_CONFIG
  # A multi-config build lists each file once per configuration, told apart by `-DCMAKE_INTDIR=\"<CONFIG>\"`
  FILTER_COMPILE_COMMANDS_FLAGS += --field 'command:-DCMAKE_INTDIR=\\"$(GAIA_BUILD_CONFIG)\\"'
endif

# Writes `compile_commands.json` from `$(BUILD_DIR)/compile_commands.json`
define filter-compile-commands
	@echo ">" compile_commands.json
	@gaia-filter-compile-commands $(FILTER_COMPILE_COMMANDS_FLAGS) \
	   <$(BUILD_DIR)/compile_commands.json >compile_commands.json
endef

# Configure memory checker ----------------------------------------------------------------------------------

ifeq ($(MEMCHECK),1)
  ifdef GAIA_OS_LINUX
    MEMCHECK_COMMAND := valgrind
    MEMCHECK_FLAGS := \
      --leak-check=full \
      --show-leak-kinds=all \
      --suppressions=$(GAIA_DIR)/src/main/valgrind/gaia-valgrind.supp \
      --track-origins=yes \
      --vgdb=no
  endif
  ifdef GAIA_OS_MACOS
    MEMCHECK_COMMAND := leaks
    MEMCHECK_FLAGS := -atExit
  endif
  ifdef GAIA_OS_WINDOWS
    $(error `MEMCHECK=1` is not available on Windows)
  endif
endif

# Configure Doxygen -----------------------------------------------------------------------------------------

DOXYGEN_FLAGS :=
ifneq ($(VERBOSE),1)
  DOXYGEN_FLAGS += -q
endif

# Targets ---------------------------------------------------------------------------------------------------

bench:
ifneq ($(wildcard $(BENCH_DIR)/),)
	@$(call print-target,$@)
	@ctest $(CTEST_FLAGS) --preset $(TEST_PRESET) \
	   --test-dir $(BUILD_DIR)/src/bench $(if $(PATTERN),-R '$(PATTERN)') -V
endif

build: configure
	@$(call print-target,$@)
	@cmake $(CMAKE_FLAGS) --build --preset $(BUILD_PRESET) \
	   $(if $(TARGET),--target $(TARGET)) $(CMAKE_TRAILING_FLAGS) </dev/null

check:
	@$(call print-target,$@)
	@run-clang-tidy \
	   -config-file=$(GAIA_DIR)/src/main/clang-tidy/clang-tidy-config.yaml \
	   -j$(GAIA_NPROC_3_4) \
	   -p. \
	   >$(CHECK_REPORT_FILE) 2>&1; \
	   status=$$?; echo report written to $(CHECK_REPORT_FILE); exit $$status

clean:
	@$(call print-target,$@)
ifdef GAIA_OS_WINDOWS
	@echo removing build directories, this may take a while ...
endif
	@cmake -E rm -rf build build-*
	@rm -rf $(shell find -name __pycache__ -type d)

configure: compile_commands.json

doc: doc-main doc-test

.PHONY: rebuild
rebuild: reconfigure build

.PHONY: reconfigure
ifeq ($(wildcard $(BUILD_DIR)/CMakeCache.txt),)
reconfigure: configure
else
reconfigure:
	@$(call print-target,$@)
ifdef GAIA_BUILD_CONFIG
	@for it in $(CONFIGS); do \
	   cmake --build --preset multi-$$it --target clean </dev/null || exit; \
	 done
else
	@cmake --build --preset $(BUILD_PRESET) --target clean </dev/null
endif
	@# Like `--fresh`, but keeps `FetchContent`’s stamps so populated dependencies are not downloaded
	@# again
	@cmake -E rm -rf $(BUILD_DIR)/CMakeCache.txt \
	   $(filter-out %/fc-stamp %/fc-tmp,$(wildcard $(BUILD_DIR)/CMakeFiles/*))
	@cmake $(CMAKE_CONFIGURE_FLAGS) --preset $(CONFIGURE_PRESET) \
	   -DFETCHCONTENT_UPDATES_DISCONNECTED=ON </dev/null
	@touch $(BUILD_DIR)/compile_commands.json
	$(filter-compile-commands)
endif

run:
	@$(call print-target,$@)
ifneq ($(MEMCHECK),1)
	$(RUN_EXECUTABLE) $(ARGS)
else
	ROCKET_EXIT=1 $(MEMCHECK_COMMAND) $(MEMCHECK_FLAGS) -- $(RUN_EXECUTABLE) $(ARGS)
endif

test:
	@$(call print-target,$@)
	@ctest $(CTEST_FLAGS) --preset $(TEST_PRESET) \
	   --test-dir $(BUILD_DIR)/src/test $(if $(PATTERN),-R '$(PATTERN)')

# `compile_commands.json` ...................................................................................

$(BUILD_DIR)/compile_commands.json: $(GAIA_DEPS) $(CMAKE_DEPS) $(CONFIGURE_DEPS)
	@$(call print-target,configure)
	@cmake $(CMAKE_CONFIGURE_FLAGS) --preset $(CONFIGURE_PRESET) </dev/null
	@# CMake may leave the file alone if its contents are unchanged. Touch it, or it may stay older than
	@# its prerequisites, and every `make` would configure again
	@touch $@

# We make this a phony target so that it is made every time. If `GAIA_BUILD_CONFIG` changes, the target must
# be remade from an older `$(BUILD_DIR)/compile_commands.json`. Being phony doesn’t keep it from depending on
# `$(BUILD_DIR)/compile_commands.json`, so a missing or outdated build directory is configured first.
.PHONY: compile_commands.json
compile_commands.json: $(BUILD_DIR)/compile_commands.json
	$(filter-compile-commands)

# Auxiliary targets .........................................................................................

# The Doxygen recipes need Bash for `pipefail`. Without it, the status of `doxygen` is lost in the pipeline
doc-main doc-test: SHELL := bash

.PHONY: doc-main
ifeq ($(wildcard src/main/Doxyfile),)
doc-main:
else
doc-main: compile_commands.json
	@$(call print-target,$@)
	@set -o pipefail; \
	   DOXYGEN_PREDEFINED="$$(gaia-compile-defines compile_commands.json /src/main/)" \
	   doxygen $(DOXYGEN_FLAGS) src/main/Doxyfile 2>&1 | { grep -v \
	   -e "warning: Incomplete input: scope for class" \
	   -e "warning: documented symbol 'T std::experimental::.*' was not declared or defined" || \
	   true; }
	@echo created $(MAIN_DIR)/doc/html/index.html
endif

.PHONY: doc-test
ifeq ($(wildcard src/test/Doxyfile),)
doc-test:
else
doc-test: compile_commands.json
	@$(call print-target,$@)
	@set -o pipefail; \
	   DOXYGEN_PREDEFINED="$$(gaia-compile-defines compile_commands.json /src/test/)" \
	   doxygen $(DOXYGEN_FLAGS) src/test/Doxyfile 2>&1 | { grep -v \
	   -e "warning: Incomplete input: scope for class" \
	   -e "warning: documented symbol 'T std::experimental::.*' was not declared or defined" || \
	   true; }
	@echo created $(TEST_DIR)/doc/html/index.html
endif

.PHONY: list-targets
list-targets: configure
	@$(call print-target,$@)
	@cmake --build --preset $(BUILD_PRESET) --target help </dev/null

# EOF
