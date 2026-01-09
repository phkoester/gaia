#
# lib.mk
#
# To be included in a Makefile. Parameters:
#
# - NAME
# - CC_FILES
# - SRC_DIR
# - SRC_ADD
# - SRC_MOVE_FRONT
# - INSTALL
#

# Collect files ---------------------------------------------------------------------------------------------

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

LIB_TARGET := $(BUILD_DIR)/lib$(NAME).a
INSTALL_TARGET := $(INSTALL_LIB_DIR)/lib$(NAME)$(G).a

ifeq ($(INSTALL),)
  TARGET := $(LIB_TARGET)
else
  TARGET := $(INSTALL_TARGET)
endif
BUILD_DEPS += $(TARGET)

$(LIB_TARGET): O_FILES := $(O_FILES)
$(LIB_TARGET): $(O_FILES)
	@echo ">" $@
	@$(AR) $(AR_FLAGS) $@ $(O_FILES)

$(INSTALL_TARGET): $(LIB_TARGET)
	@echo ">" $@
	@mkdir -p $(dir $@)
	@cp $< $@

# Clean up --------------------------------------------------------------------------------------------------

NAME :=
CC_FILES :=
SRC_DIR :=
SRC_ADD :=
SRC_MOVE_FRONT :=
INSTALL :=

# EOF
