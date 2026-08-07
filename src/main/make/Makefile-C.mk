#
# Makefile-C.mk
#
# Parameters:
#
# - ARGS
#     Arguments to pass to the run target
# - DEFAULT_RUN_TARGET
#     The default target to run
# - GAIA_BUILD_TYPE
#     The build type: `debug` or `release`
# - GAIA_CXX_TOOLCHAIN
#     The C++ toolchain: `gnu`, `llvm` or `msvc`
# - GAIA_DIR
# - JOBS
#     The number of jobs for GNU Make (0: none, N: N jobs, default: 3/4)
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
# Targets:
#
# - bench (GAIA_BUILD_TYPE, PATTERN)
# - build (GAIA_BUILD_TYPE, TARGET, VERBOSE)
# - check (GAIA_BUILD_TYPE, PATTERN)
# - clean
# - configure (GAIA_BUILD_TYPE)
# - doc (GAIA_BUILD_TYPE, VERBOSE)
# - run (ARGS, DEFAULT_RUN_TARGET, GAIA_BUILD_TYPE, TARGET)
# - test (GAIA_BUILD_TYPE, PATTERN, VERBOSE)
#

ifndef GAIA_DIR
  $(error `GAIA_DIR` not set)
endif
include $(GAIA_DIR)/src/main/make/Makefile-common.mk

# Constants -------------------------------------------------------------------------------------------------

ifdef GAIA_WINDOWS
  export BUILD_DIR := build
  ifeq ($(GAIA_BUILD_TYPE),debug)
    CONFIG := Debug
  else
    CONFIG := Release
  endif
  EXECUTABLE_DIRS := \
    $(BUILD_DIR)/src/bench/$(CONFIG) \
    $(BUILD_DIR)/src/main/$(CONFIG) \
    $(BUILD_DIR)/src/test/$(CONFIG)
  TEST_DIR := $(BUILD_DIR)/src/test/$(CONFIG)
else
  export BUILD_DIR := build/$(GAIA_BUILD_TYPE)
  CONFIG :=
  EXECUTABLE_DIRS :=
  TEST_DIR := $(BUILD_DIR)/src/test
endif

CMAKE_DEPS := CMakeLists.txt $(shell find src -name CMakeLists.txt) $(shell find cmake -type f)

ifdef GAIA_LINUX
  CONFIGURE_DEP := compile_commands.json
endif
ifdef GAIA_WINDOWS
  CONFIGURE_DEP := build/cmake_install.cmake
endif

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
  ifdef GAIA_WINDOWS
    RUN_EXECUTABLE := $(shell find $(EXECUTABLE_DIRS) -executable -name '$(TARGET).exe' -type f)
  else
    RUN_EXECUTABLE := $(shell find $(BUILD_DIR)/src -executable -name '$(TARGET)' -type f)
  endif
  ifeq ($(RUN_EXECUTABLE),)
    $(error Found no executable for target `$(TARGET)`)
  endif
endif

# Select C and C++ compilers --------------------------------------------------------------------------------

export CMAKE_TOOLCHAIN_FLAG :=

ifeq ($(GAIA_CXX_TOOLCHAIN),gnu)
  export CC := gcc
  export CXX := g++
endif
ifeq ($(GAIA_CXX_TOOLCHAIN),llvm)
  export CC := clang
  export CXX := clang++

  ifdef GAIA_WINDOWS
    CMAKE_TOOLCHAIN_FLAG := -T ClangCL
  endif
endif

# Configure CMake -------------------------------------------------------------------------------------------

CMAKE_FLAGS :=

CMAKE_TRAILING_FLAGS :=
ifeq ($(VERBOSE),1)
  CMAKE_TRAILING_FLAGS += -v
endif

ifdef GAIA_LINUX
  CONFIGURE_PRESET := linux-$(GAIA_BUILD_TYPE)
  BUILD_PRESET := linux-$(GAIA_BUILD_TYPE)
endif
ifdef GAIA_WINDOWS
  CONFIGURE_PRESET := windows
  BUILD_PRESET := windows-$(GAIA_BUILD_TYPE)
endif

# Configure CTest -------------------------------------------------------------------------------------------

CTEST_FLAGS := --output-on-failure
ifeq ($(VERBOSE),1)
  CTEST_FLAGS += -V
endif

ifdef GAIA_LINUX
  TEST_PRESET := linux-$(GAIA_BUILD_TYPE)
endif
ifdef GAIA_WINDOWS
  TEST_PRESET := windows-$(GAIA_BUILD_TYPE)
endif

# Configure Doxygen -----------------------------------------------------------------------------------------

DOXYGEN_FLAGS :=
ifneq ($(VERBOSE),1)
  DOXYGEN_FLAGS += -q
endif

# Configure GNU Make ----------------------------------------------------------------------------------------

GMAKE_FLAGS := --no-print-directory
ifdef JOBS
  ifneq ($(JOBS),0)
    GMAKE_FLAGS += -j$(JOBS)
  endif
else
  GMAKE_FLAGS += -j$(GAIA_NPROC_3_4) -l$(GAIA_NPROC)
endif

# Targets ---------------------------------------------------------------------------------------------------

bench:
ifneq ($(wildcard $(BUILD_DIR)/src/bench/),)
	@$(call print-target,$@)
	@ctest $(CTEST_FLAGS) --preset $(TEST_PRESET) --test-dir $(BUILD_DIR)/src/bench $(if $(PATTERN),-R '$(PATTERN)',) -V
endif

build: configure
	@$(call print-target,$@)
	@cmake $(CMAKE_FLAGS) \
	  --build --preset $(BUILD_PRESET) \
	  $(if $(TARGET),--target $(TARGET),) \
	  $(CMAKE_TRAILING_FLAGS) \
	  $(if $(GAIA_LINUX),-- $(GMAKE_FLAGS),)

check:
	@$(call print-target,$@)
	@run-clang-tidy \
	  -config-file=$(GAIA_DIR)/src/main/clang-tidy/gaia-config.yaml \
         -j$(GAIA_NPROC_3_4) \
	  -p. \
	  $(CHECK_FILES) 2>&1 | tee $(CHECK_REPORT_FILE)
	@echo Report written to $(CHECK_REPORT_FILE)

clean:
	@$(call print-target,$@)
	@rm -frv build

configure: $(CONFIGURE_DEP)

doc: doc-main doc-test

run:
	@$(call print-target,$@)
	@echo $$ $(RUN_EXECUTABLE) $(ARGS)
	@$(RUN_EXECUTABLE) $(ARGS)

test:
ifneq ($(wildcard $(BUILD_DIR)/src/test/),)
	@$(call print-target,$@)
	@ctest $(CTEST_FLAGS) --preset $(TEST_PRESET) --test-dir $(BUILD_DIR)/src/test $(if $(PATTERN),-R '$(PATTERN)',)
endif

# Auxiliary targets .........................................................................................

doc-main:
ifneq ($(wildcard src/main/Doxyfile),)
	@$(call print-target,$@)
	@doxygen $(DOXYGEN_FLAGS) src/main/Doxyfile
	@echo Created $(BUILD_DIR)/src/main/doc/html/index.html
endif

doc-test:
ifneq ($(wildcard src/test/Doxyfile),)
	@$(call print-target,$@)
	@doxygen $(DOXYGEN_FLAGS) src/test/Doxyfile
	@echo Created $(BUILD_DIR)/src/test/doc/html/index.html
endif

# Auxiliary targets (Linux) .................................................................................

ifdef GAIA_LINUX

$(BUILD_DIR)/compile_commands.json: $(GAIA_DEPS) $(CMAKE_DEPS)
	@$(call print-target,$@)
	@cmake $(CMAKE_FLAGS) --preset $(CONFIGURE_PRESET)

compile_commands.json: $(BUILD_DIR)/compile_commands.json
	@echo ">" $@
	@gaia-filter-compile-commands --field file -i $< -o $@ $(PROJECT_NAME)/src

endif

# Auxiliary targets (Windows) ...............................................................................

ifdef GAIA_WINDOWS

build/cmake_install.cmake: $(GAIA_DEPS) $(CMAKE_DEPS)
	@$(call print-target,$@)
	@cmake $(CMAKE_FLAGS) $(CMAKE_TOOLCHAIN_FLAG) --preset $(CONFIGURE_PRESET)

endif

# C-specific targets ----------------------------------------------------------------------------------------

list-targets: configure
	@$(call print-target,$@)
ifdef GAIA_WINDOWS
	@gaia-stem $(shell find $(EXECUTABLE_DIRS) -name "*.exe" -type f -o -name "*.lib" -type f) | sort -u
else
	@cmake --build --preset $(BUILD_PRESET) --target help
endif

# EOF
