#!/usr/bin/env bash
#
# test-cl-helper.sh
#
# Helper script for `test-cl.sh`.
#

GAIA_NO_SHELL_PRINT_STACK_TRACE=1

source "$GAIA_DIR/src/main/bash/gaia/test"

# Before parsing the command line, take arguments OPT_STRING and ARG_NAMES

if [[ $# < 2 ]]; then
  shell-error -e2 Usage: test-cl-helper.sh OPT_STRING ARG_NAMES \[ARG\]...
fi

OPT_STRING=$1
ARG_NAMES=$2
shift 2

# Parse command line

eval $(cl-get-options "$OPT_STRING" "$@")
if [[ $ARG_NAMES ]]; then
  eval $(cl-get-args $ARG_NAMES)
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

# EOF
