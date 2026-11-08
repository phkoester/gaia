#!/usr/bin/env bash
#
# test-shell.sh
#

source "$GAIA_DIR/src/main/bash/gaia/test"

# Tests -----------------------------------------------------------------------------------------------------

TEST-shell-error() {
  output=$(shell-error -r0 oops 2>&1)
  EXPECT-EQ $? 0
  EXPECT-MATCH "$output" "test-shell.sh: error: oops"

  shell-error -r2 $FUNCNAME oops 2>/dev/null
  EXPECT-EQ $? 2

  (shell-error $FUNCNAME oops 2>/dev/null)
  EXPECT-EQ $? 1

  (shell-error -e2 $FUNCNAME oops 2>/dev/null)
  EXPECT-EQ $? 2
}

TEST-shell-error-fn() {
  output=$(shell-error-fn -r0 $FUNCNAME oops 2>&1)
  EXPECT-EQ $? 0
  EXPECT-MATCH "$output" "test-shell.sh: error: In function \`TEST-shell-error-fn\`: oops"

  shell-error-fn -r2 $FUNCNAME oops 2>/dev/null
  EXPECT-EQ $? 2

  (shell-error-fn $FUNCNAME oops 2>/dev/null)
  EXPECT-EQ $? 1

  (shell-error-fn -e2 $FUNCNAME oops 2>/dev/null)
  EXPECT-EQ $? 2
}

# Main ------------------------------------------------------------------------------------------------------

RUN-ALL-TESTS "$@"

# EOF
