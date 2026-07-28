mg_cmd_version() {
  mg_require_no_args "$@"
  printf '%s\n' "$MG_VERSION"
}
