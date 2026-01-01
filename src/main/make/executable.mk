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
# - EXTERNAL_SHARED_LIB_DIRS
# - EXTERNAL_SHARED_LIBS
#

# Collect files and directories -----------------------------------------------------------------------------

ifneq ($(SRC_DIR),)
  CC_FILES := $(foreach it,$(shell find src/$(SRC_DIR) -type f -name "*.cc"),$(it:src/%=%))
  CC_FILES := $(CC_FILES) $(addprefix $(SRC_DIR)/,$(SRC_ADD))
  CC_FILES := $(call move-front,$(addprefix $(SRC_DIR)/,$(SRC_MOVE_FRONT)),$(CC_FILES))
endif
CC_D_FILES := $(foreach it,$(CC_FILES),$(BUILD_DIR)/$(it).d)
O_FILES := $(foreach it,$(CC_FILES),$(BUILD_DIR)/$(it).o)

SHARED_LIB_FILES := $(addprefix $(BUILD_DIR)/,$(SHARED_LIBS))
SHARED_LIB_DIRS := $(strip $(BUILD_DIR) $(EXTERNAL_SHARED_LIB_DIRS))

# Include dependency files ----------------------------------------------------------------------------------

-include $(CC_D_FILES)

# Target rule -----------------------------------------------------------------------------------------------

TARGET := $(BUILD_DIR)/$(NAME)$(EXECUTABLE_SUFFIX)
BUILD_DEPS += $(TARGET)

$(TARGET): EXTERNAL_SHARED_LIBS := $(EXTERNAL_SHARED_LIBS)
$(TARGET): O_FILES := $(O_FILES)
$(TARGET): LIB_FILES := $(LIB_FILES)
$(TARGET): SHARED_LIB_DIRS := $(SHARED_LIB_DIRS)
$(TARGET): SHARED_LIB_FILES := $(SHARED_LIB_FILES)
$(TARGET): SHARED_LIBS := $(SHARED_LIBS)
$(TARGET): $(O_FILES) $(LIB_FILES) $(SHARED_LIB_FILES)
	@echo ">" $@
	@$(LINK) $(addprefix -L,$(SHARED_LIB_DIRS)) $(LINK_FLAGS) \
         -o $@ \
	 $(O_FILES) $(LIB_FILES) \
	 -lstdc++_libbacktrace $(addprefix -l:,$(SHARED_LIBS) $(EXTERNAL_SHARED_LIBS))

# Clean up --------------------------------------------------------------------------------------------------

NAME :=
CC_FILES :=
SRC_DIR :=
SRC_ADD :=
SRC_MOVE_FRONT :=
LIB_FILES :=
SHARED_LIBS :=
EXTERNAL_SHARED_LIB_DIRS :=
EXTERNAL_SHARED_LIBS :=

# EOF
