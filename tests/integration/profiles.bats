#!/usr/bin/env bats
load ../test_helper

setup() { setup_workspace; }
teardown() { teardown_workspace; }

@test "create list and delete profile" {
  run "$CLI" new alpha
  [ "$status" -eq 0 ]
  run "$CLI" new beta
  [ "$status" -eq 0 ]
  run "$CLI" list
  [ "$status" -eq 0 ]
  [ "$output" = $'alpha\nbeta' ]
  run "$CLI" delete beta --yes
  [ "$status" -eq 0 ]
  [ ! -e "$MULTIGRAVITY_HOME/beta" ]
}

@test "launch opens the current directory with isolated state" {
  "$CLI" new alpha
  mkdir -p "$TEST_ROOT/project folder"
  cd "$TEST_ROOT/project folder"
  run "$CLI" launch alpha
  [ "$status" -eq 0 ]
  [[ "$output" == *"HOME=$MULTIGRAVITY_HOME/alpha"* ]]
  [[ "$output" == *"ARG=$TEST_ROOT/project folder"* ]]
}

@test "noninteractive deletion fails closed" {
  "$CLI" new alpha
  run bash -c 'printf y | "$1" delete alpha' _ "$CLI"
  [ "$status" -eq 4 ]
  [ -d "$MULTIGRAVITY_HOME/alpha" ]
}

@test "concurrent creation commits only one profile" {
  run bash -c '"$1" new alpha >/dev/null 2>&1 & a=$!; "$1" new alpha >/dev/null 2>&1 & b=$!; wait "$a"; x=$?; wait "$b"; y=$?; [[ $((x + y)) -ne 0 ]]' _ "$CLI"
  [ "$status" -eq 0 ]
  [ -d "$MULTIGRAVITY_HOME/alpha" ]
}
