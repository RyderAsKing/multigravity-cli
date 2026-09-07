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
  run env DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus" XDG_RUNTIME_DIR="/run/user/1000" "$CLI" launch alpha
  [ "$status" -eq 0 ]
  [[ "$output" == *"HOME=$MULTIGRAVITY_HOME/alpha"* ]]
  [[ "$output" == *"DBUS=<unset>"* ]]
  [[ "$output" == *"RUNTIME=$MULTIGRAVITY_HOME/alpha/run"* ]]
  [[ "$output" == *"ARG=--add-dir"* ]]
  [[ "$output" == *"ARG=$TEST_ROOT/project folder"* ]]
}

@test "launch shares host tool state but isolates Antigravity state" {
  printf '[user]\n  name = Host User\n' >"$HOME/.gitconfig"
  mkdir -p "$HOME/.ssh" "$HOME/.config/gh" "$HOME/.config/tooling" "$HOME/.local/share/keyrings" "$HOME/.local/share/kwalletd" "$HOME/.gemini" "$HOME/.antigravitycli"
  printf 'github.com:\n' >"$HOME/.config/gh/hosts.yml"
  printf 'host\n' >"$HOME/.config/tooling/settings"
  printf 'secret\n' >"$HOME/.gemini/token"
  printf 'binding\n' >"$HOME/.antigravitycli/binding.json"
  printf 'secret\n' >"$HOME/.local/share/keyrings/login.keyring"

  "$CLI" new alpha
  mkdir -p "$MULTIGRAVITY_HOME/alpha/.config/tooling" "$MULTIGRAVITY_HOME/alpha/.gemini"
  printf 'profile\n' >"$MULTIGRAVITY_HOME/alpha/.config/tooling/settings"
  run env DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus" XDG_RUNTIME_DIR="/run/user/1000" "$CLI" launch alpha
  [ "$status" -eq 0 ]

  [ "$(readlink "$MULTIGRAVITY_HOME/alpha/.gitconfig")" = "$HOME/.gitconfig" ]
  [ "$(readlink "$MULTIGRAVITY_HOME/alpha/.ssh")" = "$HOME/.ssh" ]
  [ "$(readlink "$MULTIGRAVITY_HOME/alpha/.config/gh")" = "$HOME/.config/gh" ]
  [[ "$output" == *"DBUS=<unset>"* ]]
  [[ "$output" == *"RUNTIME=$MULTIGRAVITY_HOME/alpha/run"* ]]
  [ ! -L "$MULTIGRAVITY_HOME/alpha/.config/Antigravity" ]
  [ ! -L "$MULTIGRAVITY_HOME/alpha/.antigravity" ]
  [ ! -L "$MULTIGRAVITY_HOME/alpha/.gemini" ]
  [ ! -L "$MULTIGRAVITY_HOME/alpha/.antigravitycli" ]
  [ -d "$MULTIGRAVITY_HOME/alpha/.antigravitycli" ]
  [ ! -L "$MULTIGRAVITY_HOME/alpha/.local/share/keyrings" ]
  [ -d "$MULTIGRAVITY_HOME/alpha/.local/share/keyrings" ]
  [ ! -L "$MULTIGRAVITY_HOME/alpha/.local/share/kwalletd" ]
  [ -d "$MULTIGRAVITY_HOME/alpha/.local/share/kwalletd" ]
  [ -d "$MULTIGRAVITY_HOME/alpha/run" ]
  [ "$(<"$MULTIGRAVITY_HOME/alpha/.config/tooling/settings")" = profile ]
}

@test "launch repairs legacy shared auth symlinks" {
  mkdir -p "$HOME/.antigravitycli" "$HOME/.local/share/keyrings" "$HOME/.local/share/kwalletd"
  "$CLI" new alpha
  rm -rf -- "$MULTIGRAVITY_HOME/alpha/.antigravitycli" "$MULTIGRAVITY_HOME/alpha/.local/share/keyrings" "$MULTIGRAVITY_HOME/alpha/.local/share/kwalletd" "$MULTIGRAVITY_HOME/alpha/run"
  ln -s -- "$HOME/.antigravitycli" "$MULTIGRAVITY_HOME/alpha/.antigravitycli"
  ln -s -- "$HOME/.local/share/keyrings" "$MULTIGRAVITY_HOME/alpha/.local/share/keyrings"
  ln -s -- "$HOME/.local/share/kwalletd" "$MULTIGRAVITY_HOME/alpha/.local/share/kwalletd"
  run "$CLI" launch alpha
  [ "$status" -eq 0 ]
  [ ! -L "$MULTIGRAVITY_HOME/alpha/.antigravitycli" ]
  [ -d "$MULTIGRAVITY_HOME/alpha/.antigravitycli" ]
  [ ! -L "$MULTIGRAVITY_HOME/alpha/.local/share/keyrings" ]
  [ -d "$MULTIGRAVITY_HOME/alpha/.local/share/keyrings" ]
  [ ! -L "$MULTIGRAVITY_HOME/alpha/.local/share/kwalletd" ]
  [ -d "$MULTIGRAVITY_HOME/alpha/.local/share/kwalletd" ]
  [ -d "$MULTIGRAVITY_HOME/alpha/run" ]
}

@test "launch does not link a profile root nested below the host home" {
  local nested_profiles="$HOME/AntigravityProfiles"
  env MULTIGRAVITY_HOME="$nested_profiles" "$CLI" new alpha
  run env MULTIGRAVITY_HOME="$nested_profiles" "$CLI" launch alpha
  [ "$status" -eq 0 ]
  [ ! -e "$nested_profiles/alpha/AntigravityProfiles" ]
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
