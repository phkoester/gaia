#!/usr/bin/env bash
#
# test-path.sh
#

source "$GAIA_DIR/src/main/bash/gaia/test"

# Tests -----------------------------------------------------------------------------------------------------

TEST-path-append() {
  my_path=a:b:c:bin

  EXPECT-MATCH "$(path-append my_path d 2>&1)" "Directory does not exist: \`d\`"
  
  EXPECT-NO-MATCH "$(path-append -q my_path d 2>&1)" "Directory does not exist: \`d\`"
  EXPECT-EQ $my_path a:b:c:bin

  path-append -n my_path d
  EXPECT-EQ $my_path a:b:c:bin:d
  
  path-append my_path src
  EXPECT-EQ $my_path a:b:c:bin:d:src

  path-append my_path bin
  EXPECT-EQ $my_path a:b:c:d:src:bin
}

TEST-path-list() {
  my_path=a:b:c

  EXPECT-EQ "$(path-list my_path)" a$'\n'b$'\n'c
}

TEST-path-prepend() {
  my_path=a:b:c:bin

  EXPECT-MATCH "$(path-prepend my_path d 2>&1)" "Directory does not exist: \`d\`"
  
  EXPECT-NO-MATCH "$(path-prepend -q my_path d 2>&1)" "Directory does not exist: \`d\`"
  EXPECT-EQ $my_path a:b:c:bin

  path-prepend -n my_path d
  EXPECT-EQ $my_path d:a:b:c:bin
  
  path-prepend my_path src
  EXPECT-EQ $my_path src:d:a:b:c:bin

  path-prepend my_path bin
  EXPECT-EQ $my_path bin:src:d:a:b:c
}

# Main ------------------------------------------------------------------------------------------------------

RUN-ALL-TESTS "$@"

# EOF
