mg_profile_path() { printf '%s/%s\n' "$MG_HOME" "$1"; }

mg_require_real_directory() {
  local path=$1 root=$2 resolved
  [[ -d "$path" && ! -L "$path" ]] || mg_unsafe "not a safe directory: $path"
  resolved=$(mg_realpath_existing "$path") || mg_unsafe "cannot resolve directory: $path"
  [[ "$resolved" == "$root"/* ]] || mg_unsafe "directory escapes its root: $path"
}

mg_make_stage() {
  local stage
  stage=$(mktemp -d -p "$MG_TMP_DIR" "${1}.XXXXXXXX")
  printf '%s\n' "$stage"
}
