#!/usr/bin/env bats
load ../test_helper

setup() { setup_workspace; }
teardown() { teardown_workspace; }

make_hostile_archive() {
  local kind=$1 output=$2
  python3 - "$kind" "$output" <<'PY'
import io, sys, tarfile
kind, output = sys.argv[1:]
with tarfile.open(output, "w:gz") as tf:
    manifest = b"format=1\nprofile=evil\nshared=0\n"
    info = tarfile.TarInfo("manifest"); info.size = len(manifest)
    tf.addfile(info, io.BytesIO(manifest))
    directory = tarfile.TarInfo("payload"); directory.type = tarfile.DIRTYPE
    tf.addfile(directory)
    if kind == "traversal":
        info = tarfile.TarInfo("payload/../../escaped"); info.size = 1
        tf.addfile(info, io.BytesIO(b"x"))
    elif kind == "absolute":
        info = tarfile.TarInfo("/tmp/multigravity-escaped"); info.size = 1
        tf.addfile(info, io.BytesIO(b"x"))
    elif kind == "symlink":
        info = tarfile.TarInfo("payload/link"); info.type = tarfile.SYMTYPE; info.linkname = "/tmp"
        tf.addfile(info)
    elif kind == "hardlink":
        info = tarfile.TarInfo("payload/link"); info.type = tarfile.LNKTYPE; info.linkname = "manifest"
        tf.addfile(info)
PY
}

@test "import rejects traversal absolute symlink and hardlink members" {
  local kind
  for kind in traversal absolute symlink hardlink; do
    make_hostile_archive "$kind" "$TEST_ROOT/$kind.tar.gz"
    run "$CLI" import "$TEST_ROOT/$kind.tar.gz"
    [ "$status" -eq 4 ]
    [ ! -e "$MULTIGRAVITY_HOME/evil" ]
  done
  [ ! -e /tmp/multigravity-escaped ]
}

@test "export and clone reject untrusted external links" {
  "$CLI" new alpha
  ln -s /tmp "$MULTIGRAVITY_HOME/alpha/external"
  run "$CLI" export alpha "$TEST_ROOT/output.tar.gz"
  [ "$status" -eq 4 ]
  [ ! -e "$TEST_ROOT/output.tar.gz" ]
  run "$CLI" clone alpha beta
  [ "$status" -eq 4 ]
  [ ! -e "$MULTIGRAVITY_HOME/beta" ]
}

@test "symlink profile root is rejected before deletion" {
  "$CLI" new alpha
  mv "$MULTIGRAVITY_HOME/alpha" "$TEST_ROOT/real-alpha"
  ln -s "$TEST_ROOT/real-alpha" "$MULTIGRAVITY_HOME/alpha"
  run "$CLI" delete alpha --yes
  [ "$status" -eq 4 ]
  [ -d "$TEST_ROOT/real-alpha" ]
}

@test "unsafe desktop integration rolls back profile creation" {
  mkdir -p "$HOME/.local/share" "$TEST_ROOT/external-launchers"
  ln -s "$TEST_ROOT/external-launchers" "$HOME/.local/share/applications"
  run "$CLI" new alpha
  [ "$status" -eq 4 ]
  [ ! -e "$MULTIGRAVITY_HOME/alpha" ]
  [ -z "$(find "$TEST_ROOT/external-launchers" -mindepth 1 -print -quit)" ]
}
