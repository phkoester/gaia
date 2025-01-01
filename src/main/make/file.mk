#
# file.mk
#
# To be included in a Makefile. Parameters:
#
# - NAME
# - FILE
#

# Target rule -----------------------------------------------------------------------------------------------

TARGET := $(BUILD_DIR)/$(NAME)
BUILD_DEPS += $(TARGET)
FILES += $(TARGET)

$(TARGET): FILE := $(FILE)
$(TARGET): src/$(FILE)
	@echo ">" $@
	@mkdir -p $(dir $@)
	@cp $< $@

# Clean up --------------------------------------------------------------------------------------------------

NAME :=
FILE :=

# EOF
