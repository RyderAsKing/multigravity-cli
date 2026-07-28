mg_each_profile() {
  find "$MG_HOME" -mindepth 1 -maxdepth 1 -type d \
    ! -name '.*' -print0 | sort -z
}

mg_cmd_list() {
  local raw=0 directory name
  if (($#)); then
    [[ $# == 1 && $1 == '--raw' ]] || mg_usage_error 'usage: multigravity list [--raw]'
    raw=1
  fi
  while IFS= read -r -d '' directory; do
    name=$(basename -- "$directory")
    if ((raw)); then printf '%s\n' "$name"; else printf '%-24s %s\n' "$name" "$([[ -f "$directory/.shared" ]] && printf shared || printf isolated)"; fi
  done < <(mg_each_profile)
}

mg_profile_running() {
  local name=$1 data expected pid arg found_app found_data
  data=$(mg_data_path "$name")
  expected="--user-data-dir=$data"
  [[ -d /proc ]] || return 2
  for pid in /proc/[0-9]*; do
    [[ -r "$pid/cmdline" ]] || continue
    found_app=0
    found_data=0
    while IFS= read -r -d '' arg; do
      [[ "${arg##*/}" == antigravity || "${arg##*/}" == Antigravity.AppImage ]] && found_app=1
      [[ "$arg" == "$expected" ]] && found_data=1
    done <"$pid/cmdline"
    ((found_app && found_data)) && return 0
  done
  return 1
}

mg_cmd_status() {
  mg_require_no_args "$@"
  local directory name state modified
  [[ -d /proc ]] || mg_warn 'process inspection unavailable; status will be unknown'
  while IFS= read -r -d '' directory; do
    name=$(basename -- "$directory")
    if mg_profile_running "$name"; then state=running; else
      case $? in 1) state=stopped ;; *) state=unknown ;; esac
    fi
    modified=$(stat -c '%y' -- "$directory" 2>/dev/null) || modified=unknown
    printf '%-24s %-8s %s\n' "$name" "$state" "${modified%%.*}"
  done < <(mg_each_profile)
}

mg_cmd_stats() {
  mg_require_no_args "$@"
  local directory name size extensions
  while IFS= read -r -d '' directory; do
    name=$(basename -- "$directory")
    size=$(du -sh -- "$directory" 2>/dev/null | cut -f1) || size=unknown
    extensions=0
    if [[ -d "$directory/.antigravity/extensions" ]]; then
      extensions=$(find -L "$directory/.antigravity/extensions" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
    fi
    printf '%-24s size=%-8s extensions=%s\n' "$name" "$size" "$extensions"
  done < <(mg_each_profile)
}
