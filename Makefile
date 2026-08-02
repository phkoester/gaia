#
# Makefile
#
# Parameters:
#
# - GAIA_DIR
#
# Targets:
#
# - test
#

ifndef GAIA_DIR
  $(error `GAIA_DIR` not set)
endif
include $(GAIA_DIR)/src/main/make/Makefile-bash.mk

# Test: bash ------------------------------------------------------------------------------------------------

FILE := test/bash/gaia/test-cl.sh
include src/main/make/test-script.mk

FILE := test/bash/gaia/test-path.sh
include src/main/make/test-script.mk

FILE := test/bash/gaia/test-shell.sh
include src/main/make/test-script.mk

FILE := test/bash/gaia/test-string.sh
include src/main/make/test-script.mk

# Test: Python ----------------------------------------------------------------------------------------------

FILE := test/python/gaia/test-list.py
include src/main/make/test-script.mk

FILE := test/python/gaia/test-string.py
include src/main/make/test-script.mk

# Targets ---------------------------------------------------------------------------------------------------

test: $(TEST_DEPS)

# EOF
