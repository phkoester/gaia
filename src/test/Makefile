#
# Makefile
# 

include src/main/make/Makefile.mk

# Bash ------------------------------------------------------------------------------------------------------

FILE := test/bash/gaia/test-cl.sh
include src/main/make/test-script.mk

FILE := test/bash/gaia/test-path.sh
include src/main/make/test-script.mk

FILE := test/bash/gaia/test-shell.sh
include src/main/make/test-script.mk

FILE := test/bash/gaia/test-string.sh
include src/main/make/test-script.mk

# Python ----------------------------------------------------------------------------------------------------

FILE := test/python/gaia/test-list.py
include src/main/make/test-script.mk

FILE := test/python/gaia/test-string.py
include src/main/make/test-script.mk

build: $(BUILD_DEPS)

test: $(TEST_DEPS)

TESTS_DEPS := $(addprefix test-,$(TESTS))

tests: $(TESTS_DEPS)

# EOF
