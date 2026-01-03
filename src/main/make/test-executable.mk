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
# - EXTERNAL_SHARED_LIB_DIRS
# - EXTERNAL_SHARED_LIBS
#

# Include `executable.mk` -----------------------------------------------------------------------------------

LIB_FILES += \
    ../rocket/$(BUILD_DIR)/librocket-gtest.a \
    $(GOOGLETEST_LIB_DIR)/libgmock.a \
    $(GOOGLETEST_LIB_DIR)/libgtest.a

include $(GAIA_DIR)/src/main/make/executable.mk

SAVE_TARGET := $(TARGET)

# Test target rule ------------------------------------------------------------------------------------------

TARGET := $(basename $(notdir $(SAVE_TARGET)))
TEST_DEPS += $(TARGET)

$(TARGET): ARGS := $(ARGS)
$(TARGET): SAVE_TARGET := $(SAVE_TARGET)
$(TARGET): SHARED_LIB_DIRS := $(SHARED_LIB_DIRS)
$(TARGET): $(SAVE_TARGET)
	@echo '$$' $@ $(ARGS)
	@$(SHARED_LIB_PATH_NAME)="$(SHARED_LIB_PATH):$(subst $(SPACE),:,$(SHARED_LIB_DIRS))" \
	    BUILD_DIR=$(BUILD_DIR) \
	    $(SAVE_TARGET) --gtest_catch_exceptions=0 $(ARGS)

.PHONY: $(TARGET)

# EOF
