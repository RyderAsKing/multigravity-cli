#!/usr/bin/env bats
load ../test_helper

setup() { setup_workspace; }
teardown() { teardown_workspace; }

@test "version works without creating profile storage" {
  run "$CLI" version
  [ "$status" -eq 0 ]
  [[ "$output" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-dev)?$ ]]
  [ ! -e "$MULTIGRAVITY_HOME" ]
}

@test "unknown commands fail rather than launch" {
  run "$CLI" typo
  [ "$status" -eq 2 ]
  [[ "$output" == *'unknown command: typo'* ]]
}

@test "reserved and traversal names are rejected" {
  run "$CLI" new launch
  [ "$status" -eq 4 ]
  run "$CLI" new ../escape
  [ "$status" -eq 4 ]
  [ ! -e "$TEST_ROOT/escape" ]
}

@test "launch accepts only a profile name" {
  run "$CLI" new alpha
  [ "$status" -eq 0 ]
  run "$CLI" launch alpha unexpected
  [ "$status" -eq 2 ]
}

@test "launch discovers the agy command on PATH" {
  run "$CLI" new alpha
  [ "$status" -eq 0 ]

  unset MULTIGRAVITY_APP
  PATH="$TEST_ROOT:$PATH" run "$CLI" launch alpha
  [ "$status" -eq 0 ]
  [[ "$output" == *"HOME=$MULTIGRAVITY_HOME/alpha"* ]]
}

@test "removed commands fail clearly" {
  run "$CLI" update
  [ "$status" -eq 2 ]
  [[ "$output" == *'unknown command: update'* ]]
}
