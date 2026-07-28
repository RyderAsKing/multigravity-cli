MG_EXIT_USAGE=2
MG_EXIT_NOT_FOUND=3
MG_EXIT_UNSAFE=4
MG_EXIT_DEPENDENCY=5

mg_info() {
  printf 'multigravity: %s\n' "$*" >&2
}

mg_die() {
  local code=$1
  shift
  printf 'multigravity: error: %s\n' "$*" >&2
  exit "$code"
}

mg_usage_error() { mg_die "$MG_EXIT_USAGE" "$*"; }
mg_not_found() { mg_die "$MG_EXIT_NOT_FOUND" "$*"; }
mg_unsafe() { mg_die "$MG_EXIT_UNSAFE" "$*"; }
mg_dependency_error() { mg_die "$MG_EXIT_DEPENDENCY" "$*"; }
