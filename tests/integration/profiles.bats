#!/usr/bin/env bats
load ../test_helper

setup() { setup_workspace; }
teardown() { teardown_workspace; }

@test "create list clone rename and delete profile" {
  run "$CLI" new alpha
  [ "$status" -eq 0 ]
  run "$CLI" clone alpha beta
  [ "$status" -eq 0 ]
  run "$CLI" rename beta gamma
  [ "$status" -eq 0 ]
  run "$CLI" list --raw
  [ "$status" -eq 0 ]
  [ "$output" = $'alpha\ngamma' ]
  run "$CLI" delete gamma --yes
  [ "$status" -eq 0 ]
  [ ! -e "$MULTIGRAVITY_HOME/gamma" ]
}

@test "launch preserves hostile arguments as data" {
  "$CLI" new alpha
  run "$CLI" launch alpha -- 'space value' ';touch injected' '$(touch injected2)'
  [ "$status" -eq 0 ]
  [[ "$output" == *'ARG=space value'* ]]
  [[ "$output" == *'ARG=;touch injected'* ]]
  [ ! -e injected ]
  [ ! -e injected2 ]
}

@test "template and archive round trip" {
  "$CLI" new alpha
  printf data >"$MULTIGRAVITY_HOME/alpha/example file"
  "$CLI" template save alpha base
  "$CLI" new beta --from base
  [ "$(<"$MULTIGRAVITY_HOME/beta/example file")" = data ]
  "$CLI" export alpha "$TEST_ROOT/profile.tar.gz"
  "$CLI" import "$TEST_ROOT/profile.tar.gz" restored
  [ "$(<"$MULTIGRAVITY_HOME/restored/example file")" = data ]
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
