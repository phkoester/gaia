#
# Makefile-bash.mk
#
# Parameters:
#
# - GAIA_DIR
#
# Targets:
#
# - clean
#

ifndef GAIA_DIR
  $(error `GAIA_DIR` not set)
endif
include $(GAIA_DIR)/src/main/make/Makefile-common.mk

# Targets ---------------------------------------------------------------------------------------------------

clean:
	@$(call print-target,$@)
	@rm -fv $(shell find -name "*.pyc")

# EOF
