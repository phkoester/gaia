#
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
# - bench (GAIA_BUILD_TYPE, PATTERN)
# - build (GAIA_BUILD_TYPE, TARGET, VERBOSE)
# - check (GAIA_BUILD_TYPE, PATTERN)
# - clean
# - configure (GAIA_BUILD_TYPE)
# - doc (GAIA_BUILD_TYPE, VERBOSE)
# - rebuild (GAIA_BUILD_TYPE, TARGET, VERBOSE)
# - reconfigure (GAIA_BUILD_TYPE)
# - run (ARGS, DEFAULT_RUN_TARGET, GAIA_BUILD_TYPE, MEMCHECK, TARGET, VERBOSE)
# - test (GAIA_BUILD_TYPE, PATTERN, VERBOSE)
#

ifndef GAIA_DIR
  $(error `GAIA_DIR` not set)
endif
include $(GAIA_DIR)/src/main/make/Makefile-common.mk

# Constants -------------------------------------------------------------------------------------------------

export BUILD_DIR := build/$(GAIA_BUILD_TYPE)
EXECUTABLE_SUFFIX :=
TEST_DIR := $(BUILD_DIR)/src/test

ifdef GAIA_OS_WINDOWS
  EXECUTABLE_SUFFIX := .exe
endif

CMAKE_DEPS := CMakeLists.txt $(shell find src -name CMakeLists.txt) $(wildcard cmake/*)

CHECK_FILES :=
ifeq ($(filter $(MAKECMDGOALS),check),check)
  ifneq ($(PATTERN),)
    CHECK_FILES := $(shell find src -name "*.c" -o -name "*.cc" | grep '$(PATTERN)')
    ifeq ($(CHECK_FILES),)
      $(error Found no source files for pattern `$(PATTERN)`)
    endif
  endif
endif
CHECK_REPORT_FILE := $(BUILD_DIR)/check-report.txt

RUN_EXECUTABLE :=
ifeq ($(filter $(MAKECMDGOALS),run),run)
  ifeq ($(TARGET),)
    ifeq ($(DEFAULT_RUN_TARGET),)
      $(error `DEFAULT_RUN_TARGET` not set)
    else
      TARGET := $(DEFAULT_RUN_TARGET)
    endif
  endif
  RUN_EXECUTABLE := $(shell find $(BUILD_DIR)/src -executable -name '$(TARGET)$(EXECUTABLE_SUFFIX)' -type f)
  ifeq ($(RUN_EXECUTABLE),)
    $(error Found no executable for target `$(TARGET)`)
  endif
endif

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

ifdef GAIA_OS_LINUX
  CONFIGURE_PRESET := linux-$(GAIA_BUILD_TYPE)
  BUILD_PRESET := linux-$(GAIA_BUILD_TYPE)
endif
ifdef GAIA_OS_MACOS
  CONFIGURE_PRESET := macos-$(GAIA_BUILD_TYPE)
  BUILD_PRESET := macos-$(GAIA_BUILD_TYPE)
endif
ifdef GAIA_OS_WINDOWS
  CONFIGURE_PRESET := windows-$(GAIA_BUILD_TYPE)
  BUILD_PRESET := windows-$(GAIA_BUILD_TYPE)
endif

# Configure CTest -------------------------------------------------------------------------------------------

CTEST_FLAGS := --output-on-failure
ifeq ($(VERBOSE),1)
  CTEST_FLAGS += -V
endif

ifdef GAIA_OS_LINUX
  TEST_PRESET := linux-$(GAIA_BUILD_TYPE)
endif
ifdef GAIA_OS_MACOS
  TEST_PRESET := macos-$(GAIA_BUILD_TYPE)
endif
ifdef GAIA_OS_WINDOWS
  TEST_PRESET := windows-$(GAIA_BUILD_TYPE)
endif

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
ifneq ($(wildcard $(BUILD_DIR)/src/bench/),)
	@$(call print-target,$@)
	@ctest $(CTEST_FLAGS) \
	  --preset $(TEST_PRESET) \
	  --test-dir $(BUILD_DIR)/src/bench $(if $(PATTERN),-R '$(PATTERN)',) -V
endif

build: configure
	@$(call print-target,$@)
	@cmake $(CMAKE_FLAGS) --build --preset $(BUILD_PRESET) \
	  $(if $(TARGET),--target $(TARGET),) $(CMAKE_TRAILING_FLAGS) </dev/null

check:
	@$(call print-target,$@)
	@run-clang-tidy \
	  -config-file=$(GAIA_DIR)/src/main/clang-tidy/clang-tidy-config.yaml \
	  -j$(GAIA_NPROC_3_4) \
	  -p. \
	  $(CHECK_FILES) \
	  >$(CHECK_REPORT_FILE) 2>&1; \
	  status=$$?; echo Report written to $(CHECK_REPORT_FILE); exit $$status

clean:
	@$(call print-target,$@)
ifdef GAIA_OS_WINDOWS
	@cmd //c "if exist build rmdir /q /s build"
else
	@rm -frv build
endif

configure: compile_commands.json

doc: doc-main doc-test

.PHONY: rebuild
rebuild: reconfigure build

.PHONY: reconfigure
reconfigure:
	@$(call print-target,$@)
	@cmake --build --preset $(BUILD_PRESET) --target clean </dev/null
	@cmake $(CMAKE_CONFIGURE_FLAGS) --fresh --preset $(CONFIGURE_PRESET) \
	  -DFETCHCONTENT_FULLY_DISCONNECTED=ON </dev/null
	@echo ">" compile_commands.json
	@cat $(BUILD_DIR)/compile_commands.json | \
	  gaia-filter-compile-commands --field file $(PROJECT_NAME)/src/ > compile_commands.json

run:
	@$(call print-target,$@)
ifneq ($(MEMCHECK),1)
	$(RUN_EXECUTABLE) $(ARGS)
else
	ROCKET_EXIT=1 $(MEMCHECK_COMMAND) $(MEMCHECK_FLAGS) -- $(RUN_EXECUTABLE) $(ARGS)
endif

test:
	@$(call print-target,$@)
	@ctest $(CTEST_FLAGS) \
	  --preset $(TEST_PRESET) \
	  --test-dir $(BUILD_DIR)/src/test $(if $(PATTERN),-R '$(PATTERN)',)

# `compile_commands.json` ...................................................................................

$(BUILD_DIR)/compile_commands.json: $(GAIA_DEPS) $(CMAKE_DEPS) $(CONFIGURE_DEPS)
	@$(call print-target,configure)
	@cmake $(CMAKE_CONFIGURE_FLAGS) --preset $(CONFIGURE_PRESET) </dev/null

compile_commands.json: $(BUILD_DIR)/compile_commands.json
	@echo ">" $@
	@cat $< | gaia-filter-compile-commands --field file $(PROJECT_NAME)/src/ > $@

# Auxiliary targets .........................................................................................

# The Doxygen recipes need Bash for `pipefail`. Without it, the status of `doxygen` is lost in the pipeline
doc-main doc-test: SHELL := bash

doc-main: $(if $(wildcard src/main/Doxyfile),compile_commands.json)
ifneq ($(wildcard src/main/Doxyfile),)
	@$(call print-target,$@)
	@set -o pipefail; \
	  DOXYGEN_PREDEFINED="$$(gaia-compile-defines compile_commands.json /src/main/)" \
	  doxygen $(DOXYGEN_FLAGS) src/main/Doxyfile 2>&1 | { grep -v \
	  -e "warning: Incomplete input: scope for class" \
	  -e "warning: documented symbol 'T std::experimental::.*' was not declared or defined" || \
	  true; }
	@echo Created $(BUILD_DIR)/src/main/doc/html/index.html
endif

doc-test: $(if $(wildcard src/test/Doxyfile),compile_commands.json)
ifneq ($(wildcard src/test/Doxyfile),)
	@$(call print-target,$@)
	@set -o pipefail; \
	  DOXYGEN_PREDEFINED="$$(gaia-compile-defines compile_commands.json /src/test/)" \
	  doxygen $(DOXYGEN_FLAGS) src/test/Doxyfile 2>&1 | { grep -v \
	  -e "warning: Incomplete input: scope for class" \
	  -e "warning: documented symbol 'T std::experimental::.*' was not declared or defined" || \
	  true; }
	@echo Created $(BUILD_DIR)/src/test/doc/html/index.html
endif

list-targets: configure
	@$(call print-target,$@)
	@cmake --build --preset $(BUILD_PRESET) --target help </dev/null

# EOF
