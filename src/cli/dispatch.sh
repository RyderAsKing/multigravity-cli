mg_dispatch() {
  local command=${1:-help}
  (($# == 0)) || shift
  case $command in
    new) mg_cmd_new "$@" ;;
    launch) mg_cmd_launch "$@" ;;
    list) mg_cmd_list "$@" ;;
    delete) mg_cmd_delete "$@" ;;
    version) mg_cmd_version "$@" ;;
    help | -h | --help)
      mg_require_no_args "$@"
      mg_usage
      ;;
    *) mg_usage_error "unknown command: $command" ;;
  esac
}
