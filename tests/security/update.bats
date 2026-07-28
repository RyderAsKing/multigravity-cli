#!/usr/bin/env bats
load ../test_helper

setup() {
  setup_workspace
  export MOCK_RELEASE="$TEST_ROOT/release"
  mkdir -p "$MOCK_RELEASE" "$TEST_ROOT/bin"
  VERSION=1.0.0 COMMIT=old OUTPUT="$TEST_ROOT/installed" "$BATS_TEST_DIRNAME/../../scripts/build" >/dev/null
  VERSION=1.1.0 COMMIT=new OUTPUT="$MOCK_RELEASE/multigravity-linux-all" "$BATS_TEST_DIRNAME/../../scripts/build" >/dev/null
  (cd "$MOCK_RELEASE" && sha256sum multigravity-linux-all >SHA256SUMS)
  : >"$MOCK_RELEASE/multigravity-linux-all.bundle"
  : >"$MOCK_RELEASE/SHA256SUMS.bundle"
  cat >"$TEST_ROOT/bin/curl" <<'CURL'
#!/usr/bin/env bash
set -euo pipefail
output=''
url=''
while (($#)); do
  case $1 in
    --output|-o) output=$2; shift 2 ;;
    -w) format=$2; shift 2 ;;
    http*) url=$1; shift ;;
    *) shift ;;
  esac
done
if [[ "$url" == */releases/latest ]]; then
  printf 'https://github.com/RyderAsKing/multigravity-cli/releases/tag/v1.1.0'
else
  cp -- "$MOCK_RELEASE/${url##*/}" "$output"
fi
CURL
  cat >"$TEST_ROOT/bin/cosign" <<'COSIGN'
#!/usr/bin/env bash
set -euo pipefail
[[ "${MOCK_COSIGN_FAIL:-0}" == 0 ]]
identity=''
while (($#)); do
  if [[ $1 == --certificate-identity ]]; then identity=$2; shift 2; else shift; fi
done
[[ "$identity" == 'https://github.com/RyderAsKing/multigravity-cli/.github/workflows/release.yml@refs/tags/v1.1.0' ]]
COSIGN
  chmod +x "$TEST_ROOT/bin/curl" "$TEST_ROOT/bin/cosign"
  export PATH="$TEST_ROOT/bin:$PATH"
}

teardown() { teardown_workspace; }

@test "verified update replaces atomically and retains backup" {
  run "$TEST_ROOT/installed" update --version v1.1.0
  [ "$status" -eq 0 ]
  [ "$("$TEST_ROOT/installed" version --short)" = 1.1.0 ]
  [ "$("$TEST_ROOT/installed.bak" version --short)" = 1.0.0 ]
}

@test "signature failure leaves installed artifact unchanged" {
  export MOCK_COSIGN_FAIL=1
  run "$TEST_ROOT/installed" update --version v1.1.0
  [ "$status" -eq 6 ]
  [ "$("$TEST_ROOT/installed" version --short)" = 1.0.0 ]
  [ ! -e "$TEST_ROOT/installed.bak" ]
}

@test "wrong checksum leaves installed artifact unchanged" {
  printf '%064d  multigravity-linux-all\n' 0 >"$MOCK_RELEASE/SHA256SUMS"
  run "$TEST_ROOT/installed" update --version v1.1.0
  [ "$status" -eq 6 ]
  [ "$("$TEST_ROOT/installed" version --short)" = 1.0.0 ]
  [ ! -e "$TEST_ROOT/installed.bak" ]
}

@test "downgrade is refused before download" {
  run "$TEST_ROOT/installed" update --version v0.9.0
  [ "$status" -eq 6 ]
  [ "$("$TEST_ROOT/installed" version --short)" = 1.0.0 ]
}
