#
# test-executable.mk
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

# Include `executable.mk` -----------------------------------------------------------------------------------

LIB_FILES += \
    $(INSTALL_LIB_DIR)/librocket-gtest$(G).a \
    $(INSTALL_LIB_DIR)/libgtest$(G).a \
    $(INSTALL_LIB_DIR)/libgmock$(G).a

include $(GAIA_DIR)/src/main/make/executable.mk

SAVE_TARGET := $(TARGET)

# Test target rule ------------------------------------------------------------------------------------------

TARGET := $(basename $(notdir $(SAVE_TARGET)))
TEST_DEPS += $(TARGET)

$(TARGET): ARGS := $(ARGS)
$(TARGET): SAVE_TARGET := $(SAVE_TARGET)
$(TARGET): $(SAVE_TARGET)
	@echo '$$' $@ $(ARGS)
	@BUILD_DIR=$(BUILD_DIR) $(SAVE_TARGET) --gtest_catch_exceptions=0 $(ARGS)

.PHONY: $(TARGET)

# EOF
