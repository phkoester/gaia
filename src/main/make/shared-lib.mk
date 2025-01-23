#
# shared-lib.mk
#
# To be included in a Makefile. Parameters:
#
# - NAME
# - VERSION
# - CC_FILES
# - LIB_FILES
# - SHARED_LIBS
# - EXTERNAL_SHARED_LIB_DIRS
# - EXTERNAL_SHARED_LIBS
#

# Collect files and directories -----------------------------------------------------------------------------

CC_D_FILES := $(foreach it,$(CC_FILES),$(BUILD_DIR)/$(it).d)
O_FILES := $(foreach it,$(CC_FILES),$(BUILD_DIR)/$(it).o)

SHARED_LIB_FILES := $(addprefix $(BUILD_DIR)/,$(SHARED_LIBS))
SHARED_LIB_DIRS := $(BUILD_DIR) $(EXTERNAL_SHARED_LIB_DIRS)

# Include dependency files ----------------------------------------------------------------------------------

-include $(CC_D_FILES)

# Target rule -----------------------------------------------------------------------------------------------

TARGET := $(BUILD_DIR)/$(call shared-lib-name,$(NAME),$(VERSION))
BUILD_DEPS += $(TARGET)

$(TARGET): EXTERNAL_SHARED_LIBS := $(EXTERNAL_SHARED_LIBS)
$(TARGET): O_FILES := $(O_FILES)
$(TARGET): LIB_FILES := $(LIB_FILES)
$(TARGET): SHARED_LIB_DIRS := $(SHARED_LIB_DIRS)
$(TARGET): SHARED_LIB_FILES := $(SHARED_LIB_FILES)
$(TARGET): SHARED_LIBS := $(SHARED_LIBS)
$(TARGET): $(O_FILES) $(LIB_FILES) $(SHARED_LIB_FILES)
	@echo ">" $@
	@$(LINK) -shared $(addprefix -L,$(SHARED_LIB_DIRS)) $(LINK_FLAGS) \
	 -o $@ \
	 $(O_FILES) $(LIB_FILES) \
	 -lstdc++_libbacktrace $(addprefix -l:,$(SHARED_LIBS) $(EXTERNAL_SHARED_LIBS))

# Clean up --------------------------------------------------------------------------------------------------

NAME :=
VERSION :=
CC_FILES :=
LIB_FILES :=
SHARED_LIBS :=
EXTERNAL_SHARED_LIB_DIRS :=
EXTERNAL_SHARED_LIBS :=

# EOF
