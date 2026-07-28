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

  MG_TEMPLATES_DIR="$MG_HOME/.templates"
  MG_LOCKS_DIR="$MG_HOME/.locks"
  MG_TMP_DIR="$MG_HOME/.tmp"
  mkdir -p -- "$MG_TEMPLATES_DIR" "$MG_LOCKS_DIR" "$MG_TMP_DIR"
  local internal
  for internal in "$MG_TEMPLATES_DIR" "$MG_LOCKS_DIR" "$MG_TMP_DIR"; do
    [[ -d "$internal" && ! -L "$internal" && $(mg_realpath_existing "$internal") == "$internal" ]] || mg_unsafe "unsafe internal directory: $internal"
  done
  chmod 700 -- "$MG_TEMPLATES_DIR" "$MG_LOCKS_DIR" "$MG_TMP_DIR"

  local data_configured=${XDG_DATA_HOME:-$MG_REAL_HOME/.local/share} data_parent
  [[ "$data_configured" == /* && "$data_configured" != / ]] || mg_unsafe 'XDG_DATA_HOME must be a safe absolute path'
  data_parent=$(dirname -- "$data_configured")
  mkdir -p -- "$data_parent"
  data_parent=$(mg_realpath_existing "$data_parent") || mg_unsafe 'XDG_DATA_HOME parent cannot be resolved'
  MG_DATA_HOME="$data_parent/$(basename -- "$data_configured")"
  mkdir -p -- "$MG_DATA_HOME"
  [[ -d "$MG_DATA_HOME" && ! -L "$MG_DATA_HOME" ]] || mg_unsafe 'XDG_DATA_HOME must be a real directory'
  MG_DATA_HOME=$(mg_realpath_existing "$MG_DATA_HOME")
}
