#
# Makefile-C.mk
#
# Parameters:
#
# - ARGS
#     Arguments to pass to the run target
# - CONFIGURE_DEPS
#     Targets to make before configuring
# - COVERAGE
#     If set to 1, build with code coverage and create a report when running tests (Linux and LLVM only).
#     After changing it, run `make clean`
# - DEFAULT_RUN_TARGET
#     The default target to run
# - GAIA_BUILD_TYPE
#     The build type: `debug` or `release`
# - GAIA_CXX_TOOLCHAIN
#     The C++ toolchain: `gnu`, `llvm`, or `msvc`
# - GAIA_DIR
# - JOBS
#     The number of jobs for GNU Make (0: none, N: N jobs, default: 3/4)
# - MEMCHECK
#     If set to 1, run executables with a memory checker, e.g. valgrind
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
# - build (COVERAGE, GAIA_BUILD_TYPE, TARGET, VERBOSE)
# - check (GAIA_BUILD_TYPE, PATTERN)
# - clean
# - configure (COVERAGE, GAIA_BUILD_TYPE)
# - doc (GAIA_BUILD_TYPE, VERBOSE)
# - rebuild (COVERAGE, GAIA_BUILD_TYPE, TARGET, VERBOSE)
# - reconfigure (COVERAGE, GAIA_BUILD_TYPE)
# - run (ARGS, DEFAULT_RUN_TARGET, GAIA_BUILD_TYPE, MEMCHECK, TARGET, VERBOSE)
# - test (COVERAGE, GAIA_BUILD_TYPE, PATTERN, VERBOSE)
#

ifndef GAIA_DIR
  $(error `GAIA_DIR` not set)
endif
include $(GAIA_DIR)/src/main/make/Makefile-common.mk

# Constants -------------------------------------------------------------------------------------------------

export BUILD_DIR := build/$(GAIA_BUILD_TYPE)
COVERAGE_DIR := $(BUILD_DIR)/code-coverage
EXECUTABLE_DIRS :=
TEST_DIR := $(BUILD_DIR)/src/test

ifdef GAIA_OS_WINDOWS
  EXECUTABLE_DIRS := \
    $(BUILD_DIR)/src/bench \
    $(BUILD_DIR)/src/bin \
    $(BUILD_DIR)/src/example \
    $(BUILD_DIR)/src/experimental \
    $(BUILD_DIR)/src/main \
    $(BUILD_DIR)/src/test
endif

CMAKE_DEPS := CMakeLists.txt $(shell find src -name CMakeLists.txt)

CHECK_FILES :=
ifeq ($(filter $(MAKECMDGOALS),check),check)
  ifneq ($(PATTERN),)
    CHECK_FILES := $(shell find src -name "*.c" -o -name "*.cc" | rg '$(PATTERN)')
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
  ifdef GAIA_OS_WINDOWS
    RUN_EXECUTABLE := $(shell find $(EXECUTABLE_DIRS) -executable -name '$(TARGET).exe' -type f 2> /dev/null)
  else
    RUN_EXECUTABLE := $(shell find $(BUILD_DIR)/src -executable -name '$(TARGET)' -type f)
  endif
  ifeq ($(RUN_EXECUTABLE),)
    $(error Found no executable for target `$(TARGET)`)
  endif
endif

# Select C and C++ compilers --------------------------------------------------------------------------------

ifeq ($(GAIA_CXX_TOOLCHAIN),gnu)
  export CC := gcc
  export CXX := g++
endif
ifeq ($(GAIA_CXX_TOOLCHAIN),llvm)
  ifdef GAIA_OS_WINDOWS
    # Ninja doesn't support toolsets like `-T ClangCL`, so select the MSVC-compatible driver directly
    export CC := clang-cl
    export CXX := clang-cl
  else
    export CC := clang
    export CXX := clang++
  endif
endif

# Configure code coverage -----------------------------------------------------------------------------------

ifeq ($(COVERAGE),1)
  ifndef GAIA_OS_LINUX
    $(error `COVERAGE=1` requires Linux and LLVM toolchain)
  endif
  ifneq ($(GAIA_CXX_TOOLCHAIN),llvm)
    $(error `COVERAGE=1` requires Linux and LLVM toolchain)
  endif

  export BUILD_COVERAGE := 1

  # LLVM source-based code coverage
  COVERAGE_COMPILE_FLAGS := -fprofile-instr-generate -fcoverage-mapping
  COVERAGE_LINK_FLAGS := -fprofile-instr-generate

  # Prefer the LLVM tools matching the Clang version, e.g. `llvm-cov-21`
  LLVM_VERSION := $(shell $(CC) -dumpversion | cut -d. -f1)
  LLVM_COV := $(shell command -v llvm-cov-$(LLVM_VERSION) || command -v llvm-cov)
  LLVM_PROFDATA := $(shell command -v llvm-profdata-$(LLVM_VERSION) || command -v llvm-profdata)
  ifeq ($(LLVM_COV),)
    $(error Missing `llvm-cov`)
  endif
  ifeq ($(LLVM_PROFDATA),)
    $(error Missing `llvm-profdata`)
  endif

  COVERAGE_IGNORE_REGEX := (/_deps/|/src/bench/|/src/test/)
  COVERAGE_PROFDATA := $(COVERAGE_DIR)/coverage.profdata
  COVERAGE_PROFRAW_DIR := $(abspath $(COVERAGE_DIR))/profraw
endif

# Instrumented ELF executables and shared libraries of this project (excluding `_deps`). The first one is
# passed positionally to `llvm-cov`, the others with `-object`
coverage-binaries = $(shell \
  for f in $$(find $(BUILD_DIR)/src -name CMakeFiles -prune -o -type f \( -executable -o -name '*.so*' \) -print); do \
    [ "$$(head -c4 $$f | tail -c3)" = ELF ] && echo $$f; \
  done)

coverage-objects = $(firstword $1) $(addprefix -object=,$(wordlist 2,$(words $1),$1))

# Configure valgrind ----------------------------------------------------------------------------------------

VALGRIND_FLAGS :=
ifeq ($(VERBOSE),1)
  VALGRIND_FLAGS += --leak-check=full --show-leak-kinds=all --suppressions=$(GAIA_DIR)/src/main/valgrind/gaia-valgrind.supp --track-origins=yes --vgdb=no
endif

ifeq ($(MEMCHECK),1)
  ifdef GAIA_OS_WINDOWS
    $(error `MEMCHECK=1` is not available on Windows)
  endif
endif

# Configure CMake -------------------------------------------------------------------------------------------

CMAKE_CONFIGURE_FLAGS :=

ifeq ($(COVERAGE),1)
  CMAKE_CONFIGURE_FLAGS += \
    "-DCMAKE_C_FLAGS=$(COVERAGE_COMPILE_FLAGS)" \
    "-DCMAKE_CXX_FLAGS=$(COVERAGE_COMPILE_FLAGS)" \
    "-DCMAKE_EXE_LINKER_FLAGS=$(COVERAGE_LINK_FLAGS)" \
    "-DCMAKE_SHARED_LINKER_FLAGS=$(COVERAGE_LINK_FLAGS)"
endif

CMAKE_TRAILING_FLAGS :=

ifeq ($(VERBOSE),1)
  CMAKE_TRAILING_FLAGS += -v
endif

CMAKE_FLAGS :=

ifdef GAIA_OS_LINUX
  CONFIGURE_PRESET := linux-$(GAIA_BUILD_TYPE)
  BUILD_PRESET := linux-$(GAIA_BUILD_TYPE)
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
ifdef GAIA_OS_WINDOWS
  TEST_PRESET := windows-$(GAIA_BUILD_TYPE)
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
	@ctest $(CTEST_FLAGS) --preset $(TEST_PRESET) --test-dir $(BUILD_DIR)/src/bench $(if $(PATTERN),-R '$(PATTERN)',) -V
endif

build: configure
	@$(call print-target,$@)
	@cmake $(CMAKE_FLAGS) --build --preset $(BUILD_PRESET) \
	  $(if $(TARGET),--target $(TARGET),) $(CMAKE_TRAILING_FLAGS)

check:
	@$(call print-target,$@)
	@run-clang-tidy \
	  -config-file=$(GAIA_DIR)/src/main/clang-tidy/clang-tidy-config.yaml \
	  -j$(GAIA_NPROC_3_4) \
	  -p. \
	  $(CHECK_FILES) 2>&1 | tee $(CHECK_REPORT_FILE)
	@echo Report written to $(CHECK_REPORT_FILE)

clean:
	@$(call print-target,$@)
	@rm -frv build
	@rm -frv $(shell find -name __pycache__ -type d)

configure: compile_commands.json $(CONFIGURE_DEPS)

doc: doc-main doc-test

.PHONY: rebuild
rebuild: reconfigure build

.PHONY: reconfigure
reconfigure:
	@$(call print-target,$@)
	@cmake --build --preset $(BUILD_PRESET) --target clean
	@cmake $(CMAKE_CONFIGURE_FLAGS) --fresh --preset $(CONFIGURE_PRESET) \
	  -DFETCHCONTENT_FULLY_DISCONNECTED=ON

run:
	@$(call print-target,$@)
ifneq ($(MEMCHECK),1)
	$(RUN_EXECUTABLE) $(ARGS)
else
	ROCKET_EXIT=1 valgrind $(VALGRIND_FLAGS) $(RUN_EXECUTABLE) $(ARGS)
endif

test:
	@$(call print-target,$@)
ifneq ($(COVERAGE),1)
	ctest $(CTEST_FLAGS) \
	  --preset $(TEST_PRESET) \
	  --test-dir $(BUILD_DIR)/src/test $(if $(PATTERN),-R '$(PATTERN)',)
else
	@rm -rf $(COVERAGE_DIR)
	@mkdir -p $(COVERAGE_PROFRAW_DIR)
	LLVM_PROFILE_FILE=$(COVERAGE_PROFRAW_DIR)/%p-%m.profraw ctest $(CTEST_FLAGS) \
	  --preset $(TEST_PRESET) \
	  --test-dir $(BUILD_DIR)/src/test \
          $(if $(PATTERN),-R '$(PATTERN)',)
	@$(LLVM_PROFDATA) merge -sparse -o $(COVERAGE_PROFDATA) $(COVERAGE_PROFRAW_DIR)/*.profraw
	@rm -r $(COVERAGE_PROFRAW_DIR)
	@$(LLVM_COV) show \
	  -format=html \
	  -ignore-filename-regex='$(COVERAGE_IGNORE_REGEX)' \
	  -instr-profile=$(COVERAGE_PROFDATA) \
	  -output-dir=$(COVERAGE_DIR)/html \
	  -show-line-counts-or-regions \
	  $(call coverage-objects,$(call coverage-binaries))
	@$(LLVM_COV) report \
	  -ignore-filename-regex='$(COVERAGE_IGNORE_REGEX)' \
	  -instr-profile=$(COVERAGE_PROFDATA) \
	  $(call coverage-objects,$(call coverage-binaries)) > /dev/null
	@rm -f default.profraw
	@echo Created \`$(COVERAGE_DIR)/html/index.html\`
endif

# Auxiliary targets .........................................................................................

doc-main:
ifneq ($(wildcard src/main/Doxyfile),)
	@$(call print-target,$@)
	@doxygen $(DOXYGEN_FLAGS) src/main/Doxyfile 2>&1 | grep -v \
	  -e "warning: Incomplete input: scope for class" \
	  -e "warning: documented symbol 'T std::experimental::.*' was not declared or defined" || \
          true
	@echo Created \`$(BUILD_DIR)/src/main/doc/html/index.html\`
endif

doc-test:
ifneq ($(wildcard src/test/Doxyfile),)
	@$(call print-target,$@)
	@doxygen $(DOXYGEN_FLAGS) src/test/Doxyfile 2>&1 | grep -v \
	  -e "warning: Incomplete input: scope for class" \
	  -e "warning: documented symbol 'T std::experimental::.*' was not declared or defined" || \
          true
	@echo Created \`$(BUILD_DIR)/src/test/doc/html/index.html\`
endif

# `compile_commands.json` ...................................................................................

$(BUILD_DIR)/compile_commands.json: $(GAIA_DEPS) $(CMAKE_DEPS)
	@$(call print-target,$@)
	@cmake $(CMAKE_CONFIGURE_FLAGS) --preset $(CONFIGURE_PRESET)

compile_commands.json: $(BUILD_DIR)/compile_commands.json
	@echo ">" $@
	@gaia-filter-compile-commands --field file -i $< -o $@ $(PROJECT_NAME)/src

# C-specific targets ----------------------------------------------------------------------------------------

list-targets: configure
	@$(call print-target,$@)
ifdef GAIA_OS_WINDOWS
	@gaia-stem $(shell find $(EXECUTABLE_DIRS) -name "*.exe" -type f -o -name "*.lib" -type f) | sort -u
else
	@cmake --build --preset $(BUILD_PRESET) --target help
endif

# EOF
