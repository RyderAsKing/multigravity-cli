MG_EXIT_USAGE=2
MG_EXIT_NOT_FOUND=3
MG_EXIT_UNSAFE=4
MG_EXIT_DEPENDENCY=5
MG_EXIT_UPDATE=6

mg_color_enabled() {
  [[ -t 2 && "${NO_COLOR:-}" == "" && "${TERM:-dumb}" != "dumb" ]]
}

mg_info() {
  printf 'multigravity: %s\n' "$*" >&2
}

mg_warn() {
  if mg_color_enabled; then
    printf '\033[33mmultigravity: warning: %s\033[0m\n' "$*" >&2
  else
    printf 'multigravity: warning: %s\n' "$*" >&2
  fi
}

mg_die() {
  local code=$1
  shift
  if mg_color_enabled; then
    printf '\033[31mmultigravity: error: %s\033[0m\n' "$*" >&2
  else
    printf 'multigravity: error: %s\n' "$*" >&2
  fi
  exit "$code"
}

mg_usage_error() { mg_die "$MG_EXIT_USAGE" "$*"; }
mg_not_found() { mg_die "$MG_EXIT_NOT_FOUND" "$*"; }
mg_unsafe() { mg_die "$MG_EXIT_UNSAFE" "$*"; }
mg_dependency_error() { mg_die "$MG_EXIT_DEPENDENCY" "$*"; }
