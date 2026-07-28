mg_file_size() { stat -c '%s' -- "$1"; }

mg_assert_exportable_tree() {
  local root=$1 entry
  mg_tree_has_untrusted_links "$root" && mg_unsafe 'profile contains an untrusted symbolic link'
  while IFS= read -r -d '' entry; do
    [[ -f "$entry" || -d "$entry" || -L "$entry" ]] || mg_unsafe 'profile contains an unsupported file type'
  done < <(find "$root" -mindepth 1 -print0)
}

mg_cmd_export() {
  local name=${1:-} output='' force=0 profile stage temp parent shared=0
  [[ -n "$name" ]] || mg_usage_error 'usage: multigravity export NAME [OUTPUT] [--force]'
  shift
  mg_validate_name "$name"
  while (($#)); do
    case $1 in
      --force) force=1 ;;
      --*) mg_usage_error "unknown export option: $1" ;;
      *)
        [[ -z "$output" ]] || mg_usage_error 'multiple export paths supplied'
        output=$1
        ;;
    esac
    shift
  done
  profile=$(mg_profile_path "$name")
  mg_require_real_directory "$profile" "$MG_HOME"
  mg_assert_exportable_tree "$profile"
  [[ -f "$profile/.shared" ]] && shared=1
  [[ -n "$output" ]] || output="$PWD/$name.multigravity.tar.gz"
  [[ "$output" == /* ]] || output="$PWD/$output"
  parent=$(dirname -- "$output")
  [[ -d "$parent" && ! -L "$parent" ]] || mg_unsafe 'export parent must be a real directory'
  parent=$(mg_realpath_existing "$parent")
  output="$parent/$(basename -- "$output")"
  [[ ! -d "$output" && ! -L "$output" ]] || mg_unsafe 'unsafe export destination'
  if [[ -e "$output" && $force -eq 0 ]]; then mg_unsafe 'export destination exists; use --force'; fi

  stage=$(mg_make_stage "export-$name")
  mg_register_temp "$stage"
  mkdir -- "$stage/payload"
  cp -a --no-dereference -- "$profile/." "$stage/payload/"
  if ((shared)); then
    rm -f -- "$stage/payload/.config/Antigravity" "$stage/payload/.antigravity/extensions" "$stage/payload/.shared"
  fi
  printf 'format=%s\nprofile=%s\nshared=%s\n' "$MG_ARCHIVE_FORMAT" "$name" "$shared" >"$stage/manifest"
  temp=$(mktemp -p "$parent" ".$(basename -- "$output").XXXXXXXX")
  if ! tar --format=posix --sort=name --mtime='UTC 1970-01-01' --owner=0 --group=0 --numeric-owner -czf "$temp" -C "$stage" -- manifest payload; then
    rm -rf -- "$stage"
    rm -f -- "$temp"
    mg_die 1 'export failed'
  fi
  chmod 600 "$temp"
  mv -fT -- "$temp" "$output"
  rm -rf -- "$stage"
  printf '%s\n' "$output"
}

mg_archive_validate_listing() {
  local archive=$1 count=0 member line type listing verbose manifest_count=0 payload_count=0 declared
  listing=$(tar --quoting-style=escape -tzf "$archive") || mg_unsafe 'archive listing failed'
  while IFS= read -r member; do
    ((count += 1))
    ((count <= MG_MAX_ARCHIVE_ENTRIES)) || mg_unsafe 'archive contains too many entries'
    [[ -n "$member" && "$member" != /* && "$member" != *'//'* && "$member" != *\\* ]] || mg_unsafe 'archive contains an unsafe path'
    [[ ! "$member" =~ (^|/)\.\.(/|$) && ! "$member" =~ [[:cntrl:]] ]] || mg_unsafe 'archive contains an unsafe path'
    [[ "$member" == manifest || "$member" == payload || "$member" == payload/* ]] || mg_unsafe 'archive has an invalid top-level layout'
    [[ "$member" == manifest ]] && ((manifest_count += 1))
    [[ "$member" == payload || "$member" == payload/ ]] && ((payload_count += 1))
  done <<<"$listing"
  ((count >= 2)) || mg_unsafe 'archive is incomplete'
  ((manifest_count == 1 && payload_count == 1)) || mg_unsafe 'archive must contain one manifest and one payload root'

  verbose=$(tar --quoting-style=escape --numeric-owner --full-time -tvzf "$archive") || mg_unsafe 'archive metadata listing failed'
  while IFS= read -r line; do
    type=${line:0:1}
    [[ "$type" == '-' || "$type" == d ]] || mg_unsafe 'archive contains links or special files'
  done <<<"$verbose"
  declared=$(awk '{total += $3} END {printf "%.0f\n", total}' <<<"$verbose")
  [[ "$declared" =~ ^[0-9]+$ ]] || mg_unsafe 'archive has invalid size metadata'
  ((declared <= MG_MAX_EXTRACTED_BYTES)) || mg_unsafe 'archive exceeds the declared-size limit'
}

mg_read_manifest() {
  local archive=$1 line key value format='' profile='' shared='' format_seen=0 profile_seen=0 shared_seen=0
  while IFS= read -r line; do
    key=${line%%=*}
    value=${line#*=}
    case $key in
      format)
        ((format_seen += 1))
        format=$value
        ;;
      profile)
        ((profile_seen += 1))
        profile=$value
        ;;
      shared)
        ((shared_seen += 1))
        shared=$value
        ;;
      *) mg_unsafe 'archive manifest contains an unknown field' ;;
    esac
  done < <(tar -xOzf "$archive" -- manifest)
  ((format_seen == 1 && profile_seen == 1 && shared_seen == 1)) || mg_unsafe 'archive manifest has missing or duplicate fields'
  [[ "$format" == "$MG_ARCHIVE_FORMAT" ]] || mg_unsafe 'unsupported archive format'
  mg_validate_name "$profile"
  [[ "$shared" == 0 || "$shared" == 1 ]] || mg_unsafe 'invalid shared value in archive manifest'
  MG_IMPORT_PROFILE=$profile
  MG_IMPORT_SHARED=$shared
}

mg_cmd_import() {
  local input=${1:-} requested='' source_copy work extract destination stage bytes
  [[ -n "$input" ]] || mg_usage_error 'usage: multigravity import ARCHIVE [NAME]'
  shift
  (($# <= 1)) || mg_usage_error 'usage: multigravity import ARCHIVE [NAME]'
  [[ $# == 0 ]] || requested=$1
  [[ -f "$input" && ! -L "$input" ]] || mg_unsafe 'archive must be a regular, non-symlink file'
  bytes=$(mg_file_size "$input")
  ((bytes <= MG_MAX_ARCHIVE_BYTES)) || mg_unsafe 'archive exceeds the compressed-size limit'
  work=$(mg_make_stage import)
  mg_register_temp "$work"
  source_copy="$work/archive.tar.gz"
  cp --reflink=auto -- "$input" "$source_copy"
  chmod 400 "$source_copy"
  mg_require_command tar
  mg_archive_validate_listing "$source_copy"
  mg_read_manifest "$source_copy"
  [[ -n "$requested" ]] || requested=$MG_IMPORT_PROFILE
  mg_validate_name "$requested"
  destination=$(mg_profile_path "$requested")
  [[ ! -e "$destination" && ! -L "$destination" ]] || mg_unsafe "profile already exists: $requested"
  extract="$work/extracted"
  mkdir -- "$extract"
  tar --extract --gzip --file="$source_copy" --directory="$extract" --no-same-owner --no-same-permissions --delay-directory-restore
  [[ -f "$extract/manifest" && -d "$extract/payload" && ! -L "$extract/payload" ]] || mg_unsafe 'archive extraction produced an invalid layout'
  if find "$extract" -type l -o ! -type f ! -type d | grep -q .; then mg_unsafe 'archive extraction produced an unsafe file type'; fi
  bytes=$(du -sb -- "$extract" | cut -f1)
  ((bytes <= MG_MAX_EXTRACTED_BYTES)) || mg_unsafe 'archive exceeds the extracted-size limit'

  mg_with_global_lock
  stage=$(mg_make_stage "import-$requested")
  mg_register_temp "$stage"
  cp -a --no-dereference -- "$extract/payload/." "$stage/"
  if [[ "$MG_IMPORT_SHARED" == 1 ]]; then
    mkdir -p -- "$stage/.config" "$stage/.antigravity" "$stage/.cache" "$stage/.local/share" "$stage/.local/state"
    ln -s -- "$(mg_system_data_path)" "$stage/.config/Antigravity"
    ln -s -- "$(mg_system_extensions_path)" "$stage/.antigravity/extensions"
    : >"$stage/.shared"
  else
    mg_initialize_layout "$stage"
  fi
  mg_commit_staged_profile "$stage" "$requested"
  rm -rf -- "$work"
  mg_info "imported profile: $requested"
}
