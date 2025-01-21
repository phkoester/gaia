#!/usr/bin/env bash
#
# test-cl.sh
#

source "$GAIA_DIR/src/main/bash/gaia/test"

# Local functions -------------------------------------------------------------------------------------------

# We need a helper function to test `cl-get-options-f` and `cl-get-args-f` in there
func__() {
  OUTPUT=$(func-helper__ "$@" 2>&1)
  STATUS=$?
  # echo "***" $OUTPUT > /dev/stderr # Debug
  echo $OUTPUT
}

# This function works exactly in the same manner as the helper script `test-cl-helper.sh`, except that it
# uses `cl-get-options-f` and `cl-get-args-f`
func-helper__() {
  GAIA_NO_SHELL_PRINT_STACK_TRACE=1

  # Before parsing the command line, take arguments OPT_STRING and ARG_NAMES

  if [[ $# < 2 ]]; then
    shell-error-f -r2 $FUNCNAME Usage: func-helper OPT_STRING ARG_NAMES \[ARG\]...
    GAIA_NO_SHELL_PRINT_STACK_TRACE=
    return 2
  fi

  local OPT_STRING=$1
  local ARG_NAMES=$2
  shift 2

  # Parse command line

  eval $(cl-get-options-f $FUNCNAME "$OPT_STRING" "$@")
  if [[ $ARG_NAMES ]]; then
    eval $(cl-get-args-f $FUNCNAME $ARG_NAMES)
  fi

  # Print options

  for ((i = 0; i < ${#OPT_STRING}; ++i)); do
    c=${OPT_STRING:$i:1}
    if [[ $c != : ]]; then
      eval echo $c=\$$c=
    fi
  done

  # Print named arguments

  for name in $ARG_NAMES; do
    name=${name,,} # Lowercase
    eval echo $name=\$$name=
  done

  # Print positional arguments

  for ((i = 1; i <= $#; ++i)); do
    eval echo $i=\$$i=
  done
  
  GAIA_NO_SHELL_PRINT_STACK_TRACE=
}

# We need a helper script to test `cl-get-options` and `cl-get-args` in there
script__() {
  OUTPUT=$(src/test/bash/gaia/test-cl-helper.sh "$@" 2>&1)
  STATUS=$?
  # echo "***" $OUTPUT > /dev/stderr # Debug
  echo $OUTPUT
}

# Tests -----------------------------------------------------------------------------------------------------

TEST-script() {
  EXPECT-MATCH "$(script__)" Usage:

  EXPECT-MATCH "$(script__ "")" Usage:

  EXPECT-NO-MATCH "$(script__ "" "")" Usage:
}

TEST-cl-get-options() {
  script__ "" "" -q > /dev/null
  EXPECT-MATCH "$OUTPUT" "error: Invalid option: \`-q\`"
  EXPECT-EQ $STATUS 2

  script__ vf: "" -q > /dev/null
  EXPECT-MATCH "$OUTPUT" "error: Invalid option: \`-q\`"
  EXPECT-EQ $STATUS 2

  script__ vf: "" -v -fname "a b" c > /dev/null
  EXPECT-MATCH "$OUTPUT" v=1= f=name= "1=a b=" 2=c=
  EXPECT-EQ $STATUS 0

  script__ vf: "" -f > /dev/null
  EXPECT-MATCH "$OUTPUT" "error: Option \`-f\` requires an argument"
  EXPECT-EQ $STATUS 2
}

TEST-cl-get-args() {
  script__ "" "A B" "a b" c "d e" f > /dev/null
  EXPECT-MATCH "$OUTPUT" "a=a b=" b=c= "1=d e=" 2=f=
  EXPECT-EQ $STATUS 0

  script__ "" A > /dev/null
  EXPECT-MATCH "$OUTPUT" "error: Missing argument: \`A\`"
  EXPECT-EQ $STATUS 2
}

TEST-func() {
  EXPECT-MATCH "$(func__)" Usage:

  EXPECT-MATCH "$(func__ "")" Usage:

  EXPECT-NO-MATCH "$(func__ "" "")" Usage:
}

TEST-cl-get-options-f() {
  func__ "" "" -q > /dev/null
  EXPECT-MATCH "$OUTPUT" "error: In function \`func-helper__\`: Invalid option: \`-q\`"
  EXPECT-EQ $STATUS 2

  func__ vf: "" -q > /dev/null
  EXPECT-MATCH "$OUTPUT" "error: In function \`func-helper__\`: Invalid option: \`-q\`"
  EXPECT-EQ $STATUS 2

  func__ vf: "" -v -fname "a b" c > /dev/null
  EXPECT-MATCH "$OUTPUT" v=1= f=name= "1=a b=" 2=c=
  EXPECT-EQ $STATUS 0

  func__ vf: "" -f > /dev/null
  EXPECT-MATCH "$OUTPUT" "error: In function \`func-helper__\`: Option \`-f\` requires an argument"
  EXPECT-EQ $STATUS 2
}

TEST-cl-get-args-f() {
  func__ "" "A B" "a b" c "d e" f > /dev/null
  EXPECT-MATCH "$OUTPUT" "a=a b=" b=c= "1=d e=" 2=f=
  EXPECT-EQ $STATUS 0

  func__ "" A > /dev/null
  EXPECT-MATCH "$OUTPUT" "error: In function \`func-helper__\`: Missing argument: \`A\`"
  EXPECT-EQ $STATUS 2
}

# Main ------------------------------------------------------------------------------------------------------

RUN-ALL-TESTS "$@"

# EOF
