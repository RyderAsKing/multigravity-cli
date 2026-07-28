mg_release_identity() {
  printf 'https://github.com/%s/.github/workflows/%s@refs/tags/%s\n' "$MG_REPOSITORY" "$MG_RELEASE_WORKFLOW" "$1"
}

mg_latest_release_tag() {
  local effective
  effective=$(curl -fsSIL --proto '=https' --proto-redir '=https' --tlsv1.2 -o /dev/null -w '%{url_effective}' "https://github.com/$MG_REPOSITORY/releases/latest") || return 1
  printf '%s\n' "${effective##*/}"
}

mg_verify_release_blob() {
  local blob=$1 bundle=$2 tag=$3
  cosign verify-blob \
    --bundle "$bundle" \
    --certificate-identity "$(mg_release_identity "$tag")" \
    --certificate-oidc-issuer 'https://token.actions.githubusercontent.com' \
    "$blob" >/dev/null
}

mg_cmd_update() {
  local check=0 requested='' tag current_tag compare work base target candidate checksum_line new_file backup
  while (($#)); do
    case $1 in
      --check) check=1 ;;
      --version)
        (($# >= 2)) || mg_usage_error '--version requires vX.Y.Z'
        requested=$2
        shift
        ;;
      *) mg_usage_error "unknown update option: $1" ;;
    esac
    shift
  done
  if [[ -n "$requested" ]]; then tag=$requested; else
    mg_require_command curl
    tag=$(mg_latest_release_tag) || mg_die "$MG_EXIT_UPDATE" 'could not resolve the latest release'
  fi
  mg_validate_semver_tag "$tag" || mg_die "$MG_EXIT_UPDATE" "invalid or prerelease tag: $tag"
  current_tag="v$MG_VERSION"
  mg_validate_semver_tag "$current_tag" || mg_die "$MG_EXIT_UPDATE" 'this development build cannot self-update'
  compare=$(mg_semver_compare "$tag" "$current_tag")
  if ((compare < 0)); then mg_die "$MG_EXIT_UPDATE" 'refusing to downgrade'; fi
  if ((compare == 0)); then
    mg_info "already current: $MG_VERSION"
    return
  fi
  if ((check)); then
    printf '%s\n' "${tag#v}"
    return
  fi

  mg_require_command curl
  mg_require_command cosign
  mg_require_command sha256sum

  target=$MG_EXECUTABLE
  [[ -f "$target" && ! -L "$target" && -w "$target" && -w "$(dirname -- "$target")" ]] || mg_die "$MG_EXIT_UPDATE" 'installed executable is not safely writable'
  mg_acquire_lock update
  work=$(mg_make_stage update)
  mg_register_temp "$work"
  base="https://github.com/$MG_REPOSITORY/releases/download/$tag"
  for candidate in multigravity-linux-all multigravity-linux-all.bundle SHA256SUMS SHA256SUMS.bundle; do
    curl --fail --silent --show-error --location --proto '=https' --proto-redir '=https' --tlsv1.2 \
      "$base/$candidate" --output "$work/$candidate" || mg_die "$MG_EXIT_UPDATE" "failed to download release asset: $candidate"
  done
  mg_verify_release_blob "$work/SHA256SUMS" "$work/SHA256SUMS.bundle" "$tag" || mg_die "$MG_EXIT_UPDATE" 'checksum signature verification failed'
  mg_verify_release_blob "$work/multigravity-linux-all" "$work/multigravity-linux-all.bundle" "$tag" || mg_die "$MG_EXIT_UPDATE" 'artifact signature verification failed'
  checksum_line=$(grep -E '^[0-9a-f]{64}  multigravity-linux-all$' "$work/SHA256SUMS") || mg_die "$MG_EXIT_UPDATE" 'release checksum is missing or malformed'
  [[ $(printf '%s\n' "$checksum_line" | wc -l) -eq 1 ]] || mg_die "$MG_EXIT_UPDATE" 'release checksum is ambiguous'
  (cd "$work" && printf '%s\n' "$checksum_line" | sha256sum --check --status) || mg_die "$MG_EXIT_UPDATE" 'artifact checksum verification failed'
  bash -n "$work/multigravity-linux-all" || mg_die "$MG_EXIT_UPDATE" 'downloaded artifact has invalid Bash syntax'
  chmod --reference="$target" "$work/multigravity-linux-all"
  [[ $(HOME="$MG_REAL_HOME" MULTIGRAVITY_HOME="$MG_HOME" "$work/multigravity-linux-all" version --short) == "${tag#v}" ]] || mg_die "$MG_EXIT_UPDATE" 'downloaded artifact failed its version smoke test'

  backup="$target.bak"
  new_file="$target.new.$$"
  mg_register_temp "$new_file"
  cp -p -- "$target" "$backup"
  cp -p -- "$work/multigravity-linux-all" "$new_file"
  mv -fT -- "$new_file" "$target"
  mg_info "updated to ${tag#v}; previous executable retained at $backup"
}
