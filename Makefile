#
# Makefile
#

# `build` must be the first target and build everything, including tests
build: buildTest

include src/main/make/Makefile.mk

all: test

buildMain:

buildTest: buildMain
	@$(call print-info,$@)
	@+$(MAKE) $(MAKE_FLAGS) -f src/test/Makefile build

test: buildMain
	@$(call print-info,$@)
	@+$(MAKE) $(MAKE_FLAGS) -f src/test/Makefile test

tests: buildMain
	@$(call print-info,$@)
	@+$(MAKE) $(MAKE_FLAGS) -f src/test/Makefile tests

# EOF
