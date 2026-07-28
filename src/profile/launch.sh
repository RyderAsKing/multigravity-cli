mg_cmd_launch() {
  (($# == 1)) || mg_usage_error 'usage: multigravity launch NAME'
  local name=$1 path project
  mg_validate_name "$name"
  path=$(mg_profile_path "$name")
  mg_require_real_directory "$path" "$MG_HOME"
  mg_require_app
  project=$(pwd -P)
  exec env \
    HOME="$path" \
    XDG_CONFIG_HOME="$path/.config" \
    XDG_CACHE_HOME="$path/.cache" \
    XDG_DATA_HOME="$path/.local/share" \
    XDG_STATE_HOME="$path/.local/state" \
    "$MG_APP" \
    "$project"
}
