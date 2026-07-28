mg_profile_path() { printf '%s/%s\n' "$MG_HOME" "$1"; }
mg_template_path() { printf '%s/%s\n' "$MG_TEMPLATES_DIR" "$1"; }
mg_data_path() { printf '%s/.config/Antigravity\n' "$(mg_profile_path "$1")"; }
mg_extensions_path() { printf '%s/.antigravity/extensions\n' "$(mg_profile_path "$1")"; }

mg_launcher_root() {
  printf '%s/multigravity/launchers\n' "$MG_DATA_HOME"
}

mg_launcher_path() { printf '%s/%s\n' "$(mg_launcher_root)" "$1"; }

mg_desktop_path() {
  printf '%s/applications/multigravity-%s.desktop\n' \
    "$MG_DATA_HOME" "$1"
}

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
