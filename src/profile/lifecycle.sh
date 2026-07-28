mg_commit_staged_profile() {
  local stage=$1 name=$2 destination
  destination=$(mg_profile_path "$name")
  [[ ! -e "$destination" && ! -L "$destination" ]] || mg_unsafe "profile already exists: $name"
  mv -T -- "$stage" "$destination"
}

mg_cmd_new() {
  (($# == 1)) || mg_usage_error 'usage: multigravity new NAME'
  local name=$1 stage
  mg_validate_name "$name"
  mg_with_global_lock
  stage=$(mg_make_stage "new-$name")
  mg_register_temp "$stage"
  mg_initialize_layout "$stage"
  mg_commit_staged_profile "$stage" "$name"
  mg_info "created profile: $name"
}

mg_cmd_delete() {
  local name=${1:-} yes=0 path
  [[ -n "$name" ]] || mg_usage_error 'usage: multigravity delete NAME [--yes]'
  shift
  mg_validate_name "$name"
  if (($#)); then
    [[ $# == 1 && $1 == '--yes' ]] || mg_usage_error 'usage: multigravity delete NAME [--yes]'
    yes=1
  fi
  path=$(mg_profile_path "$name")
  mg_require_real_directory "$path" "$MG_HOME"
  if ((yes == 0)); then
    [[ -t 0 ]] || mg_unsafe 'refusing noninteractive deletion; pass --yes explicitly'
    local answer
    read -r -p "Delete profile '$name' permanently? [y/N] " answer
    [[ "$answer" == y || "$answer" == Y ]] || {
      mg_info 'deletion cancelled'
      return
    }
  fi
  mg_with_global_lock
  mg_require_real_directory "$path" "$MG_HOME"
  rm -rf -- "$path"
  mg_info "deleted profile: $name"
}
