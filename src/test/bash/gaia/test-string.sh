#!/usr/bin/env bash
#
# test-string.sh
#

source "$GAIA_DIR/src/main/bash/gaia/test"

# Tests -----------------------------------------------------------------------------------------------------

TEST-string-amount() {
  EXPECT-EQ "$(string-amount 0 test tests)" "0 tests"

  EXPECT-EQ "$(string-amount 1 test tests)" "1 test"

  EXPECT-EQ "$(string-amount 2 test tests)" "2 tests"
}

TEST-string-begins-with() {
  EXPECT-SUCCESS string-begins-with gaia ""

  EXPECT-SUCCESS string-begins-with gaia gaia

  EXPECT-SUCCESS string-begins-with "Gaia is great" Gaia

  EXPECT-FAILURE string-begins-with "" gaia

  EXPECT-FAILURE string-begins-with gaia aia
}

TEST-string-ends-with() {
  EXPECT-SUCCESS string-ends-with gaia ""

  EXPECT-SUCCESS string-ends-with gaia gaia

  EXPECT-SUCCESS string-ends-with "My Gaia" Gaia

  EXPECT-FAILURE string-ends-with "" gaia

  EXPECT-FAILURE string-ends-with gaia gai
}

TEST-string-remove-leading() {
  EXPECT-EQ $(string-remove-leading gaia /) gaia

  EXPECT-EQ $(string-remove-leading /a/a/b /a) /a/b

  EXPECT-EQ $(string-remove-leading hello "") hello

  EXPECT-EQ $(string-remove-leading "" hello) ""
}

TEST-string-remove-trailing() {
  EXPECT-EQ $(string-remove-trailing gaia /) gaia

  EXPECT-EQ $(string-remove-trailing /a/b/b /b) /a/b

  EXPECT-EQ $(string-remove-trailing hello "") hello

  EXPECT-EQ $(string-remove-trailing "" hello) ""
}

TEST-string-repeat() {
  EXPECT-EQ $(string-repeat a 0) ""

  EXPECT-EQ $(string-repeat a 1) "a"

  EXPECT-EQ $(string-repeat abc 3) "abcabcabc"
}

# Main ------------------------------------------------------------------------------------------------------

RUN-ALL-TESTS "$@"

# EOF
