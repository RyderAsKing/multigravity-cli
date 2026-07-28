mg_find_app() {
  local candidate
  if [[ -n "${MULTIGRAVITY_APP:-}" ]]; then
    candidate=$MULTIGRAVITY_APP
    [[ "$candidate" == /* && -f "$candidate" && -x "$candidate" && ! -L "$candidate" ]] || return 1
    mg_realpath_existing "$candidate"
    return
  fi
  if candidate=$(command -v antigravity 2>/dev/null) && [[ -x "$candidate" ]]; then
    mg_realpath_existing "$candidate"
    return
  fi
  for candidate in /usr/bin/antigravity /usr/local/bin/antigravity "$MG_REAL_HOME/.local/bin/antigravity" "$MG_REAL_HOME/Applications/Antigravity.AppImage"; do
    if [[ -f "$candidate" && -x "$candidate" ]]; then
      mg_realpath_existing "$candidate"
      return
    fi
  done
  return 1
}

mg_require_app() {
  MG_APP=$(mg_find_app) || mg_not_found 'Antigravity executable not found; set MULTIGRAVITY_APP to an absolute executable path'
}
