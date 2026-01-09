#
# executable.mk
#
# To be included in a Makefile. Parameters:
#
# - NAME
# - CC_FILES
# - SRC_DIR
# - SRC_ADD
# - SRC_MOVE_FRONT
# - LIB_FILES
# - SHARED_LIBS
#

# Collect files and directories -----------------------------------------------------------------------------

ifneq ($(SRC_DIR),)
  CC_FILES := $(foreach it,$(shell find src/$(SRC_DIR) -type f -name "*.cc"),$(it:src/%=%))
  CC_FILES := $(CC_FILES) $(addprefix $(SRC_DIR)/,$(SRC_ADD))
  CC_FILES := $(call move-front,$(addprefix $(SRC_DIR)/,$(SRC_MOVE_FRONT)),$(CC_FILES))
endif
CC_D_FILES := $(foreach it,$(CC_FILES),$(BUILD_DIR)/$(it).d)
O_FILES := $(foreach it,$(CC_FILES),$(BUILD_DIR)/$(it).o)

# Include dependency files ----------------------------------------------------------------------------------

-include $(CC_D_FILES)

# Target rule -----------------------------------------------------------------------------------------------

TARGET := $(BUILD_DIR)/$(NAME)$(EXECUTABLE_SUFFIX)
BUILD_DEPS += $(TARGET)

SHARED_LIB_DEPS := $(shell gaia-resolve-shared-libs $(SHARED_LIBS))

$(TARGET): O_FILES := $(O_FILES)
$(TARGET): LIB_FILES := $(LIB_FILES)
$(TARGET): SHARED_LIB_DEPS := $(SHARED_LIB_DEPS)
$(TARGET): SHARED_LIBS := $(SHARED_LIBS)
$(TARGET): $(O_FILES) $(LIB_FILES) $(SHARED_LIB_DEPS)
	@echo ">" $@
	@$(LINK) $(LINK_FLAGS) -L $(INSTALL_LIB_DIR) \
            -o $@ \
	    $(O_FILES) $(LIB_FILES) \
	    -lstdc++_libbacktrace $(addprefix -l:,$(SHARED_LIBS))

# Clean up --------------------------------------------------------------------------------------------------

NAME :=
CC_FILES :=
SRC_DIR :=
SRC_ADD :=
SRC_MOVE_FRONT :=
LIB_FILES :=
SHARED_LIBS :=

# EOF
