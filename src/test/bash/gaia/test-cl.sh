#!/usr/bin/env bash
#
# test-cl.sh
#

source "$GAIA_DIR/src/main/bash/gaia/test"

# Local functions -------------------------------------------------------------------------------------------

# Usage: expect-args__ EXPECTED [ARG]...
#
# Checks that both `print-args__` and `print-args-fn__` print EXPECTED for ARG...
expect-args__() {
  local expected=$1
  shift 1

  EXPECT-SAME "$(print-args__ "$@")" "$expected"
  EXPECT-SAME "$(print-args-fn__ "$@")" "$expected"
}

# Usage: expect-opt-verbatim__ VALUE
#
# Checks that option `-m` delivers VALUE unchanged, in both separate and attached form, and with both
# `cl-get-opts` and `cl-get-opts-fn`.
expect-opt-verbatim__() {
  local value=$1 actual

  actual=$(option-value__ -m "$value")
  EXPECT-SAME "${actual%.}" "$value"

  actual=$(option-value-fn__ -m "$value")
  EXPECT-SAME "${actual%.}" "$value"

  # An empty value cannot be attached: `-m` alone would then be missing its argument
  if [[ $value ]]; then
    actual=$(option-value__ "-m$value")
    EXPECT-SAME "${actual%.}" "$value"

    actual=$(option-value-fn__ "-m$value")
    EXPECT-SAME "${actual%.}" "$value"
  fi
}

# Usage: expect-opts__ EXPECTED [ARG]...
#
# Checks that both `print-opts__` and `print-opts-fn__` print EXPECTED for ARG...
expect-opts__() {
  local expected=$1
  shift 1

  EXPECT-SAME "$(print-opts__ "$@")" "$expected"
  EXPECT-SAME "$(print-opts-fn__ "$@")" "$expected"
}

# We need a helper function to test `cl-get-opts-fn` and `cl-get-args-fn` in there
func__() {
  OUTPUT=$(func-helper__ "$@" 2>&1)
  STATUS=$?
  # echo "***" $OUTPUT >&2 # Debug
  echo $OUTPUT
}

# This function works exactly in the same manner as the helper script `test-cl-helper.sh`, except that it
# uses `cl-get-opts-fn` and `cl-get-args-fn`
func-helper__() {
  GAIA_NO_SHELL_PRINT_STACK_TRACE=1

  # Before parsing the command line, take arguments OPT_STRING and ARG_NAMES

  if (($# < 2)); then
    shell-error-fn -r2 $FUNCNAME Usage: func-helper OPT_STRING ARG_NAMES \[ARG\]...
    GAIA_NO_SHELL_PRINT_STACK_TRACE=
    return 2
  fi

  local OPT_STRING=$1
  local ARG_NAMES=$2
  shift 2

  # Parse command line

  eval "$(cl-get-opts-fn $FUNCNAME "$OPT_STRING" "$@")"
  if [[ $ARG_NAMES ]]; then
    eval $(cl-get-args-fn $FUNCNAME $ARG_NAMES)
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

# The helpers above print values with an unquoted `echo`, which collapses whitespace. These print the value
# of option `-m` exactly. The trailing `.` keeps `$(...)` from stripping trailing line feeds
option-value__() {
  eval "$(cl-get-opts m:v "$@")"
  printf '%s.' "$m"
}

option-value-fn__() {
  eval "$(cl-get-opts-fn $FUNCNAME m:v "$@")"
  printf '%s.' "$m"
}

# We need a helper script to test `cl-get-opts` and `cl-get-args` in there
script__() {
  OUTPUT=$(src/test/bash/gaia/test-cl-helper.sh "$@" 2>&1)
  STATUS=$?
  # echo "***" $OUTPUT >&2 # Debug
  echo $OUTPUT
}

# These take the named argument `A` without parsing options first
literal-args__() {
  eval $(cl-get-args A)
  printf '[%s]' "$a" "$@"
}

literal-args-fn__() {
  eval $(cl-get-args-fn $FUNCNAME A)
  printf '[%s]' "$a" "$@"
}

# These pass an empty OPT_STRING and print the remaining arguments, each one in brackets. `no-opts-fn__`
# declares a local variable first, which a bare `local` in the code from `cl-get-opts-fn` would print
no-opts__() {
  eval "$(cl-get-opts "" "$@")"
  printf '[%s]' "$@"
}

no-opts-fn__() {
  local before=1
  eval "$(cl-get-opts-fn $FUNCNAME "" "$@")"
  printf '[%s]' "$@"
}

# These print the option `-v`, the named argument `A`, and the remaining arguments, each one in brackets
print-args__() {
  eval "$(cl-get-opts v "$@")"
  eval $(cl-get-args A)
  printf '[%s]' "$v" "$a" "$@"
}

print-args-fn__() {
  eval "$(cl-get-opts-fn $FUNCNAME v "$@")"
  eval $(cl-get-args-fn $FUNCNAME A)
  printf '[%s]' "$v" "$a" "$@"
}

# These print the options `-v` and `-m` and the remaining arguments, each one in brackets, so that empty
# arguments and arguments that look like options show exactly
print-opts__() {
  eval "$(cl-get-opts m:v "$@")"
  printf '[%s]' "$v" "$m" "$@"
}

print-opts-fn__() {
  eval "$(cl-get-opts-fn $FUNCNAME m:v "$@")"
  printf '[%s]' "$v" "$m" "$@"
}

# Tests -----------------------------------------------------------------------------------------------------

TEST-script() {
  EXPECT-MATCH "$(script__)" Usage:

  EXPECT-MATCH "$(script__ "")" Usage:

  EXPECT-NO-MATCH "$(script__ "" "")" Usage:
}

TEST-cl-get-opts() {
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

TEST-cl-get-opts-fn() {
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

TEST-cl-get-args-fn() {
  func__ "" "A B" "a b" c "d e" f >/dev/null
  EXPECT-MATCH "$OUTPUT" "a=a b=" b=c= "1=d e=" 2=f=
  EXPECT-EQ $STATUS 0

  func__ "" A >/dev/null
  EXPECT-MATCH "$OUTPUT" "error: In function \`func-helper__\`: Missing argument: \`A\`"
  EXPECT-EQ $STATUS 2
}

TEST-opts-do-not-execute-values() {
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
    expect-opt-verbatim__ "$value"
  done

  EXPECT-FAILURE test -e "$marker"
  rm -rf "$tmp"
}

TEST-opts-do-not-expand-values() {
  local value
  for value in '$HOME' '${HOME}' '$((1 + 1))' '~' '*' '?' '[a-z]' '{a,b}'; do
    expect-opt-verbatim__ "$value"
  done
}

TEST-opts-preserve-whitespace() {
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
    expect-opt-verbatim__ "$value"
  done
}

TEST-opts-preserve-special-characters() {
  local value
  for value in \
    '"' "'" 'a"b' "a'b" '\' 'a\' 'a\b' '\\' '\"' "\\'" \
    '#a' '!a' '&' ';' '|' '<' '>' '(' ')' 'a=b' \
    '-n' '-e' '-v' '--' \
    'äöü €'; do
    expect-opt-verbatim__ "$value"
  done
}

TEST-opts-accept-empty-value() {
  expect-opt-verbatim__ ""
}

TEST-opts-last-value-wins() {
  local actual

  actual=$(option-value__ -m first -m 'second  value')
  EXPECT-SAME "${actual%.}" 'second  value'

  actual=$(option-value-fn__ -m first -m 'second  value')
  EXPECT-SAME "${actual%.}" 'second  value'
}

TEST-opts-unset-missing-option() {
  local actual

  actual=$(m=stale; option-value__ -v)
  EXPECT-SAME "${actual%.}" ""

  actual=$(m=stale; option-value-fn__ -v)
  EXPECT-SAME "${actual%.}" ""
}

TEST-opts-keep-positional-arguments() {
  expect-opts__ '[1][a  b][c][d  e][$(f)]' -v -m 'a  b' c 'd  e' '$(f)'
}

TEST-opts-double-dash() {
  # `--` ends the options and is removed. What follows is positional, even if it looks like an option
  expect-opts__ '[1][][-m][x]' -v -- -m x
  expect-opts__ '[][][-v]' -- -v
  expect-opts__ '[][][-q]' -- -q # Not a valid option, but no error, because it is positional
  expect-opts__ '[][][]' -- ''
  expect-opts__ '[1][a][b]' -vma -- b

  # `--` alone leaves no positional arguments
  expect-opts__ '[][]' --
  expect-opts__ '[1][]' -v --

  # Only the first `--` is removed
  expect-opts__ '[1][a][--][b]' -v -m a -- -- b

  # Parsing stops at the first nonoption, so a later `--` is just another positional argument
  expect-opts__ '[][][a][--][-v]' a -- -v

  # As the value of an option, `--` does not end the options
  expect-opts__ '[1][--]' -m -- -v
  expect-opts__ '[][--][x]' -m -- -- x
}

TEST-opts-double-dash-script() {
  # The same through the helper script, where `getopts` works on the script's own arguments, and through the
  # helper function
  script__ vf: "" -v -- -f x >/dev/null
  EXPECT-MATCH "$OUTPUT" v=1= f== 1=-f= 2=x=
  EXPECT-NO-MATCH "$OUTPUT" "=--=" "(^| )3="
  EXPECT-EQ $STATUS 0

  func__ vf: "" -v -- -f x >/dev/null
  EXPECT-MATCH "$OUTPUT" v=1= f== 1=-f= 2=x=
  EXPECT-NO-MATCH "$OUTPUT" "=--=" "(^| )3="
  EXPECT-EQ $STATUS 0
}

TEST-opts-ignore-caller-optind() {
  # A caller that runs `getopts` itself leaves `OPTIND` changed. Parsing must start at the first argument
  # anyway, or the arguments in front of `--` would be skipped
  local actual

  actual=$(OPTIND=2; print-opts__ -v -- -m x)
  EXPECT-SAME "$actual" '[1][][-m][x]'

  actual=$(OPTIND=2; print-opts-fn__ -v -- -m x)
  EXPECT-SAME "$actual" '[1][][-m][x]'
}

TEST-opts-empty-opt-string() {
  # With an empty OPT_STRING, nothing is declared and nothing is printed. `--` is still removed
  EXPECT-SAME "$(no-opts__ a b)" '[a][b]'
  EXPECT-SAME "$(no-opts-fn__ a b)" '[a][b]'

  EXPECT-SAME "$(no-opts__ -- -a)" '[-a]'
  EXPECT-SAME "$(no-opts-fn__ -- -a)" '[-a]'
}

TEST-args-double-dash() {
  # Once `--` is removed, `A` takes the next argument, even if that looks like an option or is another `--`
  expect-args__ '[1][-x][y]' -v -- -x y
  expect-args__ '[][-v]' -- -v
  expect-args__ '[][--][y]' -- -- y
  expect-args__ '[][a][--][y]' a -- y

  script__ v A -v -- -x y >/dev/null
  EXPECT-MATCH "$OUTPUT" v=1= a=-x= 1=y=
  EXPECT-NO-MATCH "$OUTPUT" "=--="
  EXPECT-EQ $STATUS 0

  func__ v A -v -- -x y >/dev/null
  EXPECT-MATCH "$OUTPUT" v=1= a=-x= 1=y=
  EXPECT-NO-MATCH "$OUTPUT" "=--="
  EXPECT-EQ $STATUS 0

  # `--` is not an argument, so `A` is missing
  script__ "" A -- >/dev/null
  EXPECT-MATCH "$OUTPUT" "error: Missing argument: \`A\`"
  EXPECT-EQ $STATUS 2

  func__ "" A -- >/dev/null
  EXPECT-MATCH "$OUTPUT" "error: In function \`func-helper__\`: Missing argument: \`A\`"
  EXPECT-EQ $STATUS 2
}

TEST-args-take-double-dash-literally() {
  # Without option parsing in front, `--` is an ordinary argument
  local actual

  actual=$(literal-args__ -- y)
  EXPECT-SAME "$actual" '[--][y]'

  actual=$(literal-args-fn__ -- y)
  EXPECT-SAME "$actual" '[--][y]'
}

TEST-opts-invalid-option-characters() {
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

TEST-opts-stop-at-first-invalid-option() {
  local output

  output=$(cl-get-opts m: -x -y)
  EXPECT-EQ $? 2
  EXPECT-SAME "$output" 'shell-error -e2 Invalid option: \`-x\`'

  output=$(cl-get-opts-fn my-func m: -x -y)
  EXPECT-EQ $? 2
  EXPECT-SAME "$output" 'shell-error-fn -r2 "my-func" Invalid option: \`-x\`; return 2'
}

# Main ------------------------------------------------------------------------------------------------------

RUN-ALL-TESTS "$@"

# EOF
