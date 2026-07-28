setup_workspace() {
  TEST_ROOT=$(mktemp -d)
  export HOME="$TEST_ROOT/home"
  export MULTIGRAVITY_HOME="$TEST_ROOT/profiles"
  mkdir -p "$HOME"
  CLI="$BATS_TEST_DIRNAME/../../dist/multigravity"
  export MULTIGRAVITY_APP="$TEST_ROOT/agy"
  cat >"$MULTIGRAVITY_APP" <<'APP'
#!/usr/bin/env bash
printf 'HOME=%s\n' "$HOME"
printf 'PWD=%s\n' "$PWD"
printf 'ARG=%s\n' "$@"
APP
  chmod +x "$MULTIGRAVITY_APP"
}

teardown_workspace() { rm -rf -- "$TEST_ROOT"; }
