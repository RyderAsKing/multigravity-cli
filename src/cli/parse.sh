mg_cmd_version() {
  if (($#)); then
    [[ $# == 1 && $1 == '--short' ]] || mg_usage_error 'usage: multigravity version [--short]'
    printf '%s\n' "$MG_VERSION"
    return
  fi
  printf 'multigravity %s\ncommit: %s\nrepository: https://github.com/%s\n' "$MG_VERSION" "$MG_BUILD_COMMIT" "$MG_REPOSITORY"
}
