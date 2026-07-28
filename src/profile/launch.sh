mg_cmd_launch() {
  local name=${1:-} path data extensions
  [[ -n "$name" ]] || mg_usage_error 'usage: multigravity launch NAME [-- APP_ARGUMENTS...]'
  shift
  mg_validate_name "$name"
  if (($#)); then
    [[ $1 == '--' ]] || mg_usage_error 'forwarded application arguments must follow --'
    shift
  fi
  path=$(mg_profile_path "$name")
  mg_require_real_directory "$path" "$MG_HOME"
  mg_require_app
  data="$path/.config/Antigravity"
  extensions="$path/.antigravity/extensions"
  exec env \
    HOME="$path" \
    XDG_CONFIG_HOME="$path/.config" \
    XDG_CACHE_HOME="$path/.cache" \
    XDG_DATA_HOME="$path/.local/share" \
    XDG_STATE_HOME="$path/.local/state" \
    "$MG_APP" \
    "--user-data-dir=$data" \
    "--extensions-dir=$extensions" \
    "$@"
}
