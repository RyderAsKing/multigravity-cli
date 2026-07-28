mg_dispatch() {
  local command=${1:-help}
  (($# == 0)) || shift
  case $command in
    new) mg_cmd_new "$@" ;;
    launch) mg_cmd_launch "$@" ;;
    list) mg_cmd_list "$@" ;;
    status) mg_cmd_status "$@" ;;
    rename) mg_cmd_rename "$@" ;;
    delete) mg_cmd_delete "$@" ;;
    clone) mg_cmd_clone "$@" ;;
    template) mg_cmd_template "$@" ;;
    export) mg_cmd_export "$@" ;;
    import) mg_cmd_import "$@" ;;
    update) mg_cmd_update "$@" ;;
    doctor) mg_cmd_doctor "$@" ;;
    stats) mg_cmd_stats "$@" ;;
    completion) mg_cmd_completion "$@" ;;
    version) mg_cmd_version "$@" ;;
    help | -h | --help)
      mg_require_no_args "$@"
      mg_usage
      ;;
    *) mg_usage_error "unknown command: $command" ;;
  esac
}
