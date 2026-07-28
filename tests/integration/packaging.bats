#!/usr/bin/env bats
load ../test_helper

setup() { setup_workspace; }
teardown() { teardown_workspace; }

@test "local installer and uninstaller preserve profiles" {
  local release="$TEST_ROOT/multigravity-linux-all" prefix="$TEST_ROOT/prefix"
  VERSION=1.2.3 COMMIT=test OUTPUT="$release" "$BATS_TEST_DIRNAME/../../scripts/build" >/dev/null
  run "$BATS_TEST_DIRNAME/../../scripts/install" "$release" --prefix "$prefix"
  [ "$status" -eq 0 ]
  run "$prefix/bin/multigravity" version --short
  [ "$output" = '1.2.3' ]
  mkdir -p "$MULTIGRAVITY_HOME/keep"
  run "$BATS_TEST_DIRNAME/../../scripts/uninstall" --prefix "$prefix"
  [ "$status" -eq 0 ]
  [ ! -e "$prefix/bin/multigravity" ]
  [ -d "$MULTIGRAVITY_HOME/keep" ]
}
