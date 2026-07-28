mg_linux_require_base_tools() {
  local tool
  for tool in bash readlink mktemp mv rm mkdir find sort; do mg_require_command "$tool"; done
}
