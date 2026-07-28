mg_each_profile() {
  find "$MG_HOME" -mindepth 1 -maxdepth 1 -type d \
    ! -name '.*' -print0 | sort -z
}

mg_cmd_list() {
  mg_require_no_args "$@"
  local directory
  while IFS= read -r -d '' directory; do
    basename -- "$directory"
  done < <(mg_each_profile)
}
