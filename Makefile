#
# Makefile
#

# 'build' must be the first target and build everything, including tests
build: buildTest

include src/main/make/Makefile.mk

all: test

buildMain:

buildTest: buildMain
	@$(call printInfo,$@)
	@+$(MAKE) $(MAKE_FLAGS) -f src/test/Makefile build
	@echo Done.

test: buildMain
	@$(call printInfo,$@)
	@+$(MAKE) $(MAKE_FLAGS) -f src/test/Makefile test
	@echo Done.

tests: buildMain
	@$(call printInfo,$@)
	@+$(MAKE) $(MAKE_FLAGS) -f src/test/Makefile tests
	@echo Done.

# EOF
