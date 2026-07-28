mg_linux_require_base_tools() {
  local tool
  for tool in bash readlink mktemp cp mv rm mkdir; do mg_require_command "$tool"; done
}

mg_system_data_path() { printf '%s/.config/Antigravity\n' "$MG_REAL_HOME"; }
mg_system_extensions_path() { printf '%s/.antigravity/extensions\n' "$MG_REAL_HOME"; }
