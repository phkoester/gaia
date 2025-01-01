#
# test-script.mk
#
# To be included in a Makefile. Parameters:
#
# - ARGS
# - FILE

# Test target rule ------------------------------------------------------------------------------------------

TARGET := $(basename $(subst /,-,$(subst test-,,$(FILE))))
TEST_DEPS += $(TARGET)

$(TARGET): ARGS := $(ARGS)
$(TARGET): FILE := $(FILE)
$(TARGET): build
	@echo '$$' $@ $(ARGS)
	@src/$(FILE) -v $(ARGS)

.PHONY: $(TARGET)

# Clean up --------------------------------------------------------------------------------------------------

FILE :=

# EOF
