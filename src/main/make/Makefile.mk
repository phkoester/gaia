#
# Makefile.mk
#
# Parameters:
#
# - COMPILE_DEPS
# - INCLUDE_DIRS
# - SYSTEM_INCLUDE_DIRS
#
# Options:
#
# - PP
#     If nonempty, prints preprocessor output only
# - VERBOSE
#     If nonempty, the makefiles and some executed binaries may output more detailed information
#

# Check prerequisites ---------------------------------------------------------------------------------------

ifeq ($(GAIA_VERSION),)
  $(error Gaia not initialized)
endif

ifeq ($(GAIA_CXX_TOOLCHAIN),)
  GAIA_CXX_TOOLCHAIN=$(GAIA_DEFAULT_CXX_TOOLCHAIN)
endif
ifeq ($(filter $(GAIA_CXX_TOOLCHAIN),gnu llvm),)
  $(error 'GAIA_CXX_TOOLCHAIN': Invalid value '$(GAIA_CXX_TOOLCHAIN)'; expected 'gnu' or 'llvm')
endif

ifeq ($(GAIA_BUILD_TYPE),)
  GAIA_BUILD_TYPE=$(GAIA_DEFAULT_BUILD_TYPE)
endif
ifeq ($(filter $(GAIA_BUILD_TYPE),debug release),)
  $(error 'GAIA_BUILD_TYPE': Invalid value '$(GAIA_BUILD_TYPE)'; expected 'debug' or 'release')
endif

# Constants -------------------------------------------------------------------------------------------------

COMMA := ,
EMPTY :=
SPACE := $(EMPTY) $(EMPTY)

BUILD_DIR := target/$(GAIA_TARGET_SYSTEM)-$(GAIA_TARGET_ARCH)-$(GAIA_CXX_TOOLCHAIN)-$(GAIA_BUILD_TYPE)
export BUILD_DIR # Used in 'Doxyfile'
CXX_STD := gnu++2b
MAKE_FLAGS := --no-print-directory
MAKEFILE_DEPS := \
    $(shell find -type f -name Makefile) \
    $(shell find $(GAIA_DIR)/src/main/make -type f -name "*.mk")

# Variables -------------------------------------------------------------------------------------------------

# These must be initialized once, otherwise '+=' doesn't work as expected
BUILD_DEPS :=
FILES :=
LIB_FILES :=
SHARED_LIBS :=
TEST_DEPS :=

# Some functions --------------------------------------------------------------------------------------------

# $1: Directory
hexVersion = $(shell python3 -c 'import gaia; gaia.hexVersion("$1")')

lower = $(shell echo $1 | tr A-Z -az)

# $1 Items to move to the back
# $2 All items
moveBack = $(filter-out $1,$2) $1

# $1 Items to move to the front
# $2 All items
moveFront = $1 $(filter-out $1,$2)

# $1: Target
define printInfo
$(info ####################)
$(info #)
$(info # $(notdir $(realpath .)): $1 ($(GAIA_CXX_TOOLCHAIN), $(GAIA_BUILD_TYPE)))
$(info #)
$(info ####################)

endef

unique = $(if $1,$(firstword $1) $(call unique,$(filter-out $(firstword $1),$1)))

upper = $(shell echo $1 | tr a-z A-Z)

# $1: Directory
version = $(shell python3 -c 'import gaia; gaia.version("$1")')

# $1: Directory
versionCode = $(shell python3 -c 'import gaia; gaia.versionCode("$1")')

# Binaries and options (gnu, llvm) --------------------------------------------------------------------------

ifeq ($(GAIA_CXX_GNU),)
  GAIA_CXX_GNU := $(shell which g++)
else
  DIR := $(realpath $(dir $(GAIA_CXX_GNU))/..)
endif

ifeq ($(GAIA_CXX_LLVM),)
  GAIA_CXX_LLVM := $(shell which clang++)
else
  DIR := $(realpath $(dir $(GAIA_CXX_LLVM))/..)
endif

ifeq ($(GAIA_CXX_TOOLCHAIN),gnu)
  CXX := $(GAIA_CXX_GNU)
  AR  := $(dir $(CXX))/ar
else
  CXX := $(GAIA_CXX_LLVM)
  AR  := $(dir $(CXX))/llvm-ar
endif

ifeq ($(CXX),)
  $(error 'CXX': Invalid value ''; cannot locate C++ compiler for toolchain '$(GAIA_CXX_TOOLCHAIN)')
endif
ifeq ($(AR),)
  $(error 'AR': Invalid value ''; cannot locate archiver for toolchain '$(GAIA_CXX_TOOLCHAIN)')
endif

AR_FLAGS := -rc

# -D_GLIBCXX_DEFINE_STDEXCEPT_COPY_OPS
CXX_FLAGS := \
    -DBOOST_SPIRIT_UNICODE \
    -DGAIA_CXX_TOOLCHAIN_$(call upper,$(GAIA_CXX_TOOLCHAIN)) \
    -DGAIA_TARGET_OS_FAMILY_$(call upper,$(GAIA_TARGET_OS_FAMILY)) \
    -DGAIA_TARGET_SYSTEM_$(call upper,$(GAIA_TARGET_SYSTEM)) \
    -Wall -Werror \
    -fPIC -fmessage-length=0 -fsized-deallocation \
    -pthread \
    -std=$(CXX_STD)

ifeq ($(GAIA_CXX_TOOLCHAIN),gnu)
  CXX_FLAGS += -Wno-ignored-attributes
endif

ifeq ($(GAIA_BUILD_TYPE),debug)
  CXX_FLAGS += -DGAIA_DEBUG -O0 -g3
else
  CXX_FLAGS += -O3
endif

LINK := $(CXX)

LINK_FLAGS := -pthread -static-libstdc++

# Configure for target platform -----------------------------------------------------------------------------

ifeq ($(GAIA_TARGET_OS_FAMILY),win)
  EXECUTABLE_SUFFIX := .exe
  # No colon in the next line!
  SHARED_LIB_PATH = $(PATH)
  SHARED_LIB_PATH_NAME := PATH

  # $1: Base name
  # $2: Version
  sharedLibName = $1$(if $2,-$2).dll
else
  EXECUTABLE_SUFFIX :=
  # No colon in the next line!
  SHARED_LIB_PATH = $(LD_LIBRARY_PATH)
  SHARED_LIB_PATH_NAME := LD_LIBRARY_PATH

  # $1: Base name
  # $2: Version
  sharedLibName = lib$1.so$(if $2,.$2)
endif

# Include directories ---------------------------------------------------------------------------------------

BUILD_INCLUDE_DIRS := $(addprefix $(BUILD_DIR)/,$(INCLUDE_DIRS))
SRC_INCLUDE_DIRS := $(addprefix src/,$(INCLUDE_DIRS))
ALL_INCLUDE_DIRS := $(BUILD_INCLUDE_DIRS) $(SRC_INCLUDE_DIRS)

CXX_FLAGS_NO_INCLUDES := $(CXX_FLAGS)

CXX_FLAGS += $(foreach it,$(SYSTEM_INCLUDE_DIRS),-isystem "$(it)")
CXX_FLAGS += $(foreach it,$(ALL_INCLUDE_DIRS),-I"$(it)")

# Doxygen ---------------------------------------------------------------------------------------------------

ifeq ($(GAIA_DOXYGEN),)
  DOXYGEN := doxygen
else
  DOXYGEN := $(GAIA_DOXYGEN)
endif

DOXYGEN_FLAGS :=
ifeq ($(VERBOSE),)
  DOXYGEN_FLAGS += -q
endif

# 'compile_commands.json' -----------------------------------------------------------------------------------

# (empty) | 1
COMPILE_COMMANDS :=
ifneq ($(wildcard .compile_commands),) # Look for file '.compile_commands' in project directory
  COMPILE_COMMANDS := 1
endif

ifeq ($(COMPILE_COMMANDS),1)

compile_commands.json: build
	@echo ">" $@
	@echo [ > $@
	@# sed: Delete comma at end of last line
	@cat $(shell find $(BUILD_DIR) -type f -name "*.cc.json") | sed -e '$$s/,$$//' >> $@
	@echo ] >> $@

compile_commands: compile_commands.json

.PHONY: compile_commands compile_commands.json

endif

# Cppcheck --------------------------------------------------------------------------------------------------

CPPCHECK_FLAGS := \
    -DGAIA_CXX_TOOLCHAIN_$(call upper,$(GAIA_CXX_TOOLCHAIN)) \
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

ifeq ($(COMPILE_COMMANDS),1)
check: compile_commands.json
	@$(call printInfo,$@)
	@mkdir -p $(BUILD_DIR)/cppcheck
	@cppcheck $(CPPCHECK_FLAGS)
	@echo Done.
endif

.PHONY: check

# Predefined targets ----------------------------------------------------------------------------------------

clean:
	@$(call printInfo,$@)
	@rm -rf $(BUILD_DIR)
	@echo Done.

cxxDefines:
	@$(call printInfo,$@)
	@$(CXX) -dM -E -x c /dev/null

cxxIncludes:
	@$(call printInfo,$@)
	@$(CXX) -E -x c++ - -v < /dev/null

info:
	@$(call printInfo,$@)
	@echo
	@echo "Host platform  : $(GAIA_HOST)"
	@echo "Target platform: $(GAIA_TARGET)"
	@echo "C++ toolchain  : $(GAIA_CXX_TOOLCHAIN)"
	@echo "Build type     : $(GAIA_BUILD_TYPE)"
	@echo "Build directory: $(BUILD_DIR)"
	@echo
	@echo Current Gaia settings:
	@printenv | grep ^GAIA_ | grep -v ^GAIA_COLOR | sort | sed 's/^/  /'
	@echo Done.

.PHONY: all build buildMain buildTest clean cxxDefines cxxIncludes doc docMain docTest info test tests

# Pattern rules ---------------------------------------------------------------------------------------------

# src/%.cc -> $(BUILD_DIR)/%.cc.o ...........................................................................

$(BUILD_DIR)/%.cc.o: D_FILE = $(@:%.o=%.d)
$(BUILD_DIR)/%.cc.o: JSON_FILE = $(@:%.o=%.json)
$(BUILD_DIR)/%.cc.o: src/%.cc $(COMPILE_DEPS) $(MAKEFILE_DEPS)
	@mkdir -p $(dir $@)
	@echo ">" $@
ifneq ($(PP),)
	@# Show preprocessor output only
	@$(CXX) $(CXX_FLAGS) -E -P $<
else ifeq ($(COMPILE_COMMANDS),)
	@# No compile commands required: run 'CXX'
	@$(CXX) $(CXX_FLAGS) -c -o $@ -MMD -MP -MT $@ -MF $(D_FILE) $<
else ifeq ($(GAIA_CXX_TOOLCHAIN),gnu)
	@# Compile commands required, toolchain 'gnu': run 'CXX', then run 'GAIA_CXX_LLVM' to create JSON
	@# file
	@$(CXX) $(CXX_FLAGS) -c -o $@ -MMD -MP -MT $@ -MF $(D_FILE) $<
	@$(GAIA_CXX_LLVM) $(CXX_FLAGS) -E -MM -MJ $(JSON_FILE) $< > /dev/null
else
	@# Compile commands required, toolchain 'llvm': run 'CXX'
	@$(CXX) $(CXX_FLAGS) -c -o $@ -MMD -MP -MT $@ -MF $(D_FILE) -MJ $(JSON_FILE) $<
endif

# $(BUILD_DIR)/%.cc -> $(BUILD_DIR)/%.cc.o ..................................................................

$(BUILD_DIR)/%.cc.o: D_FILE = $(@:%.o=%.d)
$(BUILD_DIR)/%.cc.o: JSON_FILE = $(@:%.o=%.json)
$(BUILD_DIR)/%.cc.o: $(BUILD_DIR)/%.cc $(COMPILE_DEPS) $(MAKEFILE_DEPS)
	@mkdir -p $(dir $@)
	@echo ">" $@
ifneq ($(PP),)
	@# Show preprocessor output only
	@$(CXX) $(CXX_FLAGS) -E -P $<
else ifeq ($(COMPILE_COMMANDS),)
	@# No compile commands required: run 'CXX'
	@$(CXX) $(CXX_FLAGS) -c -o $@ -MMD -MP -MT $@ -MF $(D_FILE) $<
else ifeq ($(GAIA_CXX_TOOLCHAIN),gnu)
	@# Compile commands required, toolchain 'gnu': run 'CXX', then run 'GAIA_CXX_LLVM' to create JSON
	@# file
	@$(CXX) $(CXX_FLAGS) -c -o $@ -MMD -MP -MT $@ -MF $(D_FILE) $<
	@$(GAIA_CXX_LLVM) $(CXX_FLAGS) -E -MM -MJ $(JSON_FILE) $< > /dev/null
else
	@# Compile commands required, toolchain 'llvm': run 'CXX'
	@$(CXX) $(CXX_FLAGS) -c -o $@ -MMD -MP -MT $@ -MF $(D_FILE) -MJ $(JSON_FILE) $<
endif

# EOF