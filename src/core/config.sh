mg_realpath_existing() {
  readlink -f -- "$1"
}

mg_config_init() {
  [[ "$(uname -s)" == "Linux" ]] || mg_dependency_error "only Linux is supported"
  [[ -n "${HOME:-}" && "$HOME" == /* ]] || mg_unsafe 'HOME must be an absolute path'

  MG_REAL_HOME=$(mg_realpath_existing "$HOME") || mg_unsafe 'HOME cannot be resolved'
  local configured=${MULTIGRAVITY_HOME:-$MG_REAL_HOME/AntigravityProfiles}
  [[ "$configured" == /* ]] || mg_unsafe 'MULTIGRAVITY_HOME must be absolute'
  [[ "$configured" != "/" && "$configured" != "$MG_REAL_HOME" ]] || mg_unsafe 'unsafe profile root'

  local parent
  parent=$(dirname -- "$configured")
  mkdir -p -- "$parent"
  parent=$(mg_realpath_existing "$parent") || mg_unsafe 'profile root parent cannot be resolved'
  MG_HOME="$parent/$(basename -- "$configured")"
  mkdir -p -- "$MG_HOME"
  [[ ! -L "$MG_HOME" ]] || mg_unsafe 'profile root must not be a symbolic link'
  MG_HOME=$(mg_realpath_existing "$MG_HOME") || mg_unsafe 'profile root cannot be resolved'
  [[ "$MG_HOME" != "/" && "$MG_HOME" != "$MG_REAL_HOME" ]] || mg_unsafe 'unsafe profile root'

  MG_LOCKS_DIR="$MG_HOME/.locks"
  MG_TMP_DIR="$MG_HOME/.tmp"
  mkdir -p -- "$MG_LOCKS_DIR" "$MG_TMP_DIR"
  local internal
  for internal in "$MG_LOCKS_DIR" "$MG_TMP_DIR"; do
    [[ -d "$internal" && ! -L "$internal" && $(mg_realpath_existing "$internal") == "$internal" ]] || mg_unsafe "unsafe internal directory: $internal"
  done
  chmod 700 -- "$MG_LOCKS_DIR" "$MG_TMP_DIR"
}
