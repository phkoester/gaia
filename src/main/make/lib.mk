#
# lib.mk
#
# To be included in a Makefile. Parameters:
#
# - NAME
# - CC_FILES
#

# Collect files ---------------------------------------------------------------------------------------------

CC_D_FILES := $(foreach it,$(CC_FILES),$(BUILD_DIR)/$(it).d)
O_FILES := $(foreach it,$(CC_FILES),$(BUILD_DIR)/$(it).o)

# Include dependency files ----------------------------------------------------------------------------------

-include $(CC_D_FILES)

# Target rule -----------------------------------------------------------------------------------------------

TARGET := $(BUILD_DIR)/lib$(NAME).a
BUILD_DEPS += $(TARGET)

$(TARGET): O_FILES := $(O_FILES)
$(TARGET): $(O_FILES) 
	@echo ">" $@
	@$(AR) $(AR_FLAGS) $@ $(O_FILES)

# Clean up --------------------------------------------------------------------------------------------------

NAME :=
CC_FILES :=

# EOF
