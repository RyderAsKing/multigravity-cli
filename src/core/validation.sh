MG_RESERVED_NAMES=(new launch list status rename delete clone template export import update doctor stats completion version help)

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

mg_validate_semver_tag() {
  [[ "$1" =~ ^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]]
}

mg_semver_compare() {
  local a=${1#v} b=${2#v} i
  local IFS=.
  local -a av bv
  read -r -a av <<<"$a"
  read -r -a bv <<<"$b"
  for i in 0 1 2; do
    if ((10#${av[i]} > 10#${bv[i]})); then
      printf '1\n'
      return
    fi
    if ((10#${av[i]} < 10#${bv[i]})); then
      printf '%s\n' '-1'
      return
    fi
  done
  printf '0\n'
}
