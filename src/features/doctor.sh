mg_cmd_doctor() {
  mg_require_no_args "$@"
  local failed=0 tool app
  printf 'Version: %s (%s)\n' "$MG_VERSION" "$MG_BUILD_COMMIT"
  printf 'Profiles: %s\n' "$MG_HOME"
  for tool in bash readlink tar curl sha256sum; do
    if command -v "$tool" >/dev/null 2>&1; then printf 'ok: %s\n' "$tool"; else
      printf 'missing: %s\n' "$tool"
      failed=1
    fi
  done
  if app=$(mg_find_app); then printf 'ok: Antigravity (%s)\n' "$app"; else
    printf 'missing: Antigravity\n'
    failed=1
  fi
  if command -v cosign >/dev/null 2>&1; then printf 'ok: cosign\n'; else printf 'missing: cosign (required for updates)\n'; fi
  return "$failed"
}
