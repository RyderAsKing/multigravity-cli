mg_cmd_template() {
  local action=${1:-}
  [[ -n "$action" ]] || mg_usage_error 'usage: multigravity template save|list|delete ...'
  shift
  case $action in
    save)
      (($# == 2)) || mg_usage_error 'usage: multigravity template save PROFILE NAME'
      local profile=$1 name=$2 source destination stage
      mg_validate_name "$profile"
      mg_validate_name "$name"
      source=$(mg_profile_path "$profile")
      destination=$(mg_template_path "$name")
      mg_require_real_directory "$source" "$MG_HOME"
      [[ ! -e "$destination" && ! -L "$destination" ]] || mg_unsafe "template already exists: $name"
      mg_with_global_lock
      stage=$(mg_make_stage "template-$name")
      mg_register_temp "$stage"
      mg_copy_profile_tree "$source" "$stage"
      mv -T -- "$stage" "$destination"
      mg_info "saved template: $name"
      ;;
    list)
      mg_require_no_args "$@"
      local item
      while IFS= read -r -d '' item; do basename -- "$item"; done < <(find "$MG_TEMPLATES_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
      ;;
    delete)
      (($# >= 1 && $# <= 2)) || mg_usage_error 'usage: multigravity template delete NAME [--yes]'
      local name=$1 yes=${2:-} destination
      mg_validate_name "$name"
      destination=$(mg_template_path "$name")
      mg_require_real_directory "$destination" "$MG_TEMPLATES_DIR"
      if [[ "$yes" != '--yes' ]]; then
        [[ -z "$yes" ]] || mg_usage_error 'usage: multigravity template delete NAME [--yes]'
        [[ -t 0 ]] || mg_unsafe 'refusing noninteractive deletion; pass --yes explicitly'
        local answer
        read -r -p "Delete template '$name' permanently? [y/N] " answer
        [[ "$answer" == y || "$answer" == Y ]] || return
      fi
      mg_with_global_lock
      rm -rf -- "$destination"
      mg_info "deleted template: $name"
      ;;
    *) mg_usage_error "unknown template action: $action" ;;
  esac
}
