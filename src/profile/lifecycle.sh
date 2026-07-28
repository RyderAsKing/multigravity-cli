mg_commit_staged_profile() {
  local stage=$1 name=$2 destination
  destination=$(mg_profile_path "$name")
  [[ ! -e "$destination" && ! -L "$destination" ]] || mg_unsafe "profile already exists: $name"
  mg_prepare_shortcut_dirs
  mv -T -- "$stage" "$destination"
  if ! mg_create_shortcut "$name"; then
    rm -rf -- "$destination"
    mg_die 1 'profile shortcut creation failed; profile rolled back'
  fi
}

mg_cmd_new() {
  local name=${1:-} shared=0 template='' stage source
  [[ -n "$name" ]] || mg_usage_error 'usage: multigravity new NAME [--shared | --from TEMPLATE]'
  shift
  mg_validate_name "$name"
  while (($#)); do
    case $1 in
      --shared)
        shared=1
        shift
        ;;
      --from)
        (($# >= 2)) || mg_usage_error '--from requires a template'
        template=$2
        shift 2
        ;;
      *) mg_usage_error "unknown new option: $1" ;;
    esac
  done
  ((shared == 0 || ${#template} == 0)) || mg_usage_error '--shared and --from cannot be combined'
  mg_with_global_lock
  stage=$(mg_make_stage "new-$name")
  mg_register_temp "$stage"
  if [[ -n "$template" ]]; then
    mg_validate_name "$template"
    source=$(mg_template_path "$template")
    mg_require_real_directory "$source" "$MG_TEMPLATES_DIR"
    mg_copy_profile_tree "$source" "$stage"
  elif ((shared)); then
    mg_initialize_shared_layout "$stage"
  else
    mg_initialize_layout "$stage"
  fi
  mg_commit_staged_profile "$stage" "$name"
  mg_info "created profile: $name"
}

mg_cmd_clone() {
  (($# == 2)) || mg_usage_error 'usage: multigravity clone SOURCE DESTINATION'
  local source_name=$1 destination_name=$2 source stage
  mg_validate_name "$source_name"
  mg_validate_name "$destination_name"
  mg_with_global_lock
  source=$(mg_profile_path "$source_name")
  mg_require_real_directory "$source" "$MG_HOME"
  stage=$(mg_make_stage "clone-$destination_name")
  mg_register_temp "$stage"
  mg_copy_profile_tree "$source" "$stage"
  mg_commit_staged_profile "$stage" "$destination_name"
  mg_info "cloned $source_name to $destination_name"
}

mg_cmd_rename() {
  (($# == 2)) || mg_usage_error 'usage: multigravity rename OLD NEW'
  local old=$1 new=$2 source destination
  mg_validate_name "$old"
  mg_validate_name "$new"
  mg_with_global_lock
  mg_prepare_shortcut_dirs
  source=$(mg_profile_path "$old")
  destination=$(mg_profile_path "$new")
  mg_require_real_directory "$source" "$MG_HOME"
  [[ ! -e "$destination" && ! -L "$destination" ]] || mg_unsafe "profile already exists: $new"
  mv -T -- "$source" "$destination"
  if ! mg_create_shortcut "$new"; then
    mv -T -- "$destination" "$source"
    mg_die 1 'rename rolled back after shortcut failure'
  fi
  mg_remove_shortcut "$old"
  mg_info "renamed $old to $new"
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
  mg_prepare_shortcut_dirs
  mg_require_real_directory "$path" "$MG_HOME"
  rm -rf -- "$path"
  mg_remove_shortcut "$name"
  mg_info "deleted profile: $name"
}
