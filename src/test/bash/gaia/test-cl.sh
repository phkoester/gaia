


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
  # echo "***" $OUTPUT >/dev/stderr # Debug
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

  eval "$(cl-get-options-f $FUNCNAME "$OPT_STRING" "$@")"
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
  # echo "***" $OUTPUT >/dev/stderr # Debug
  echo $OUTPUT
}

# The helpers above print values with an unquoted `echo`, which collapses whitespace. These print the value
# of option `-m` exactly. The trailing `.` keeps `$(...)` from stripping trailing line feeds
option-value__() {
  eval "$(cl-get-options m:v "$@")"
  printf '%s.' "$m"
}

option-value-f__() {
  eval "$(cl-get-options-f $FUNCNAME m:v "$@")"
  printf '%s.' "$m"
}

# Usage: expect-option-verbatim__ VALUE
#
# Checks that option `-m` delivers VALUE unchanged, in both separate and attached form, and with both
# `cl-get-options` and `cl-get-options-f`.
expect-option-verbatim__() {
  local value=$1 actual

  actual=$(option-value__ -m "$value")
  EXPECT-SAME "${actual%.}" "$value"

  actual=$(option-value-f__ -m "$value")
  EXPECT-SAME "${actual%.}" "$value"

  # An empty value cannot be attached: `-m` alone would then be missing its argument
  if [[ $value ]]; then
    actual=$(option-value__ "-m$value")
    EXPECT-SAME "${actual%.}" "$value"

    actual=$(option-value-f__ "-m$value")
    EXPECT-SAME "${actual%.}" "$value"
  fi
}

# Tests -----------------------------------------------------------------------------------------------------

TEST-script() {
  EXPECT-MATCH "$(script__)" Usage:

  EXPECT-MATCH "$(script__ "")" Usage:

  EXPECT-NO-MATCH "$(script__ "" "")" Usage:
}

TEST-cl-get-options() {
  script__ "" "" -q >/dev/null
  EXPECT-MATCH "$OUTPUT" "error: Invalid option: \`-q\`"
  EXPECT-EQ $STATUS 2

  script__ vf: "" -q >/dev/null
  EXPECT-MATCH "$OUTPUT" "error: Invalid option: \`-q\`"
  EXPECT-EQ $STATUS 2

  script__ vf: "" -v -fname "a b" c >/dev/null
  EXPECT-MATCH "$OUTPUT" v=1= f=name= "1=a b=" 2=c=
  EXPECT-EQ $STATUS 0

  script__ vf: "" -f >/dev/null
  EXPECT-MATCH "$OUTPUT" "error: Option \`-f\` requires an argument"
  EXPECT-EQ $STATUS 2
}

TEST-cl-get-args() {
  script__ "" "A B" "a b" c "d e" f >/dev/null
  EXPECT-MATCH "$OUTPUT" "a=a b=" b=c= "1=d e=" 2=f=
  EXPECT-EQ $STATUS 0

  script__ "" A >/dev/null
  EXPECT-MATCH "$OUTPUT" "error: Missing argument: \`A\`"
  EXPECT-EQ $STATUS 2
}

TEST-func() {
  EXPECT-MATCH "$(func__)" Usage:

  EXPECT-MATCH "$(func__ "")" Usage:

  EXPECT-NO-MATCH "$(func__ "" "")" Usage:
}

TEST-cl-get-options-f() {
  func__ "" "" -q >/dev/null
  EXPECT-MATCH "$OUTPUT" "error: In function \`func-helper__\`: Invalid option: \`-q\`"
  EXPECT-EQ $STATUS 2

  func__ vf: "" -q >/dev/null
  EXPECT-MATCH "$OUTPUT" "error: In function \`func-helper__\`: Invalid option: \`-q\`"
  EXPECT-EQ $STATUS 2

  func__ vf: "" -v -fname "a b" c >/dev/null
  EXPECT-MATCH "$OUTPUT" v=1= f=name= "1=a b=" 2=c=
  EXPECT-EQ $STATUS 0

  func__ vf: "" -f >/dev/null
  EXPECT-MATCH "$OUTPUT" "error: In function \`func-helper__\`: Option \`-f\` requires an argument"
  EXPECT-EQ $STATUS 2
}

TEST-cl-get-args-f() {
  func__ "" "A B" "a b" c "d e" f >/dev/null
  EXPECT-MATCH "$OUTPUT" "a=a b=" b=c= "1=d e=" 2=f=
  EXPECT-EQ $STATUS 0

  func__ "" A >/dev/null
  EXPECT-MATCH "$OUTPUT" "error: In function \`func-helper__\`: Missing argument: \`A\`"
  EXPECT-EQ $STATUS 2
}

TEST-options-do-not-execute-values() {
  local tmp marker value
  tmp=$(mktemp -d)
  marker=$tmp/injected

  for value in \
    "\`touch $marker\`" \
    "Fix \`touch $marker\` here" \
    "\$(touch $marker)" \
    "; touch $marker" \
    "| touch $marker" \
    "&& touch $marker" \
    "\"; touch $marker; \"" \
    "'; touch $marker; '" \
    "\\\"; touch $marker; \\\""; do
    expect-option-verbatim__ "$value"
  done

  EXPECT-FAILURE test -e "$marker"
  rm -rf "$tmp"
}

TEST-options-do-not-expand-values() {
  local value
  for value in '$HOME' '${HOME}' '$((1 + 1))' '~' '*' '?' '[a-z]' '{a,b}'; do
    expect-option-verbatim__ "$value"
  done
}

TEST-options-preserve-whitespace() {
  local value
  for value in \
    'two   spaces' \
    ' leading' \
    'trailing ' \
    '   ' \
    $'tab\there' \
    $'line\nfeed' \
    $'trailing line feed\n' \
    $'a  b\tc*  d'; do
    expect-option-verbatim__ "$value"
  done
}

TEST-options-preserve-special-characters() {
  local value
  for value in \
    '"' "'" 'a"b' "a'b" '\' 'a\' 'a\b' '\\' '\"' "\\'" \
    '#a' '!a' '&' ';' '|' '<' '>' '(' ')' 'a=b' \
    '-n' '-e' '-v' '--' \
    'äöü €'; do
    expect-option-verbatim__ "$value"
  done
}

TEST-options-accept-empty-value() {
  expect-option-verbatim__ ""
}

TEST-options-last-value-wins() {
  local actual

  actual=$(option-value__ -m first -m 'second  value')
  EXPECT-SAME "${actual%.}" 'second  value'

  actual=$(option-value-f__ -m first -m 'second  value')
  EXPECT-SAME "${actual%.}" 'second  value'
}

TEST-options-unset-missing-option() {
  local actual

  actual=$(m=stale; option-value__ -v)
  EXPECT-SAME "${actual%.}" ""

  actual=$(m=stale; option-value-f__ -v)
  EXPECT-SAME "${actual%.}" ""
}

TEST-options-keep-positional-arguments() {
  local actual

  # Print the options and the remaining arguments, each one in brackets
  print__() {
    eval "$(cl-get-options m:v "$@")"
    printf '[%s]' "$v" "$m" "$@"
  }
  print-f__() {
    eval "$(cl-get-options-f $FUNCNAME m:v "$@")"
    printf '[%s]' "$v" "$m" "$@"
  }

  actual=$(print__ -v -m 'a  b' c 'd  e' '$(f)')
  EXPECT-SAME "$actual" '[1][a  b][c][d  e][$(f)]'

  actual=$(print-f__ -v -m 'a  b' c 'd  e' '$(f)')
  EXPECT-SAME "$actual" '[1][a  b][c][d  e][$(f)]'

  unset -f print__ print-f__
}

TEST-options-invalid-option-characters() {
  local option
  for option in q ';' '$' "'" '"' '`' '&' '*' '(' '|' '<'; do
    script__ m: "" "-$option" >/dev/null
    EXPECT-CONTAINS "$OUTPUT" "error: Invalid option: \`-$option\`"
    EXPECT-EQ $STATUS 2

    func__ m: "" "-$option" >/dev/null
    EXPECT-CONTAINS "$OUTPUT" "error: In function \`func-helper__\`: Invalid option: \`-$option\`"
    EXPECT-EQ $STATUS 2
  done
}

TEST-options-stop-at-first-invalid-option() {
  local output

  output=$(cl-get-options m: -x -y)
  EXPECT-EQ $? 2
  EXPECT-SAME "$output" 'shell-error -e2 Invalid option: \`-x\`'

  output=$(cl-get-options-f my-func m: -x -y)
  EXPECT-EQ $? 2
  EXPECT-SAME "$output" 'shell-error-f -r2 "my-func" Invalid option: \`-x\`; return 2'
}

# Main ------------------------------------------------------------------------------------------------------

RUN-ALL-TESTS "$@"

# EOF
