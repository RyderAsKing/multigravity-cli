MG_RESERVED_NAMES=(new launch list delete version help)

mg_validate_name() {
  local name=${1:-} reserved
  [[ ${#name} -ge 1 && ${#name} -le 64 ]] || mg_unsafe 'profile names must contain 1-64 characters'
  [[ "$name" =~ ^[A-Za-z0-9][A-Za-z0-9_-]*$ ]] || mg_unsafe "invalid profile name: $name"
  for reserved in "${MG_RESERVED_NAMES[@]}"; do
    [[ "$name" != "$reserved" ]] || mg_unsafe "reserved profile name: $name"
  done
}

mg_require_no_args() {
  (($# == 0)) || mg_usage_error 'unexpected arguments'
}

mg_require_command() {
  command -v "$1" >/dev/null 2>&1 || mg_dependency_error "required command not found: $1"
}
