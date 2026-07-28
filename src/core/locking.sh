MG_HELD_LOCKS=()
MG_TEMP_PATHS=()

mg_cleanup() {
  local lock path
  for lock in "${MG_HELD_LOCKS[@]:-}"; do rmdir -- "$lock" 2>/dev/null || true; done
  for path in "${MG_TEMP_PATHS[@]:-}"; do
    [[ -e "$path" || -L "$path" ]] && rm -rf -- "$path"
  done
  MG_HELD_LOCKS=()
  MG_TEMP_PATHS=()
}

mg_register_temp() { MG_TEMP_PATHS+=("$1"); }

mg_acquire_lock() {
  local key=$1 lock="$MG_LOCKS_DIR/$1.lock"
  if ! mkdir -- "$lock" 2>/dev/null; then
    mg_die "$MG_EXIT_UNSAFE" "another operation holds lock: $key"
  fi
  MG_HELD_LOCKS+=("$lock")
}

mg_with_global_lock() { mg_acquire_lock global; }
