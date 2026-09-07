mg_initialize_layout() {
  local root=$1
  mkdir -p -- \
    "$root/.config/Antigravity" \
    "$root/.cache" \
    "$root/.local/share/keyrings" \
    "$root/.local/share/kwalletd" \
    "$root/.local/state" \
    "$root/.antigravity/extensions" \
    "$root/.antigravitycli" \
    "$root/run"
  chmod 700 -- "$root/.config/Antigravity" "$root/.cache" "$root/.local/share" "$root/.local/state" "$root/.antigravity/extensions" "$root/.antigravitycli" "$root/.local/share/keyrings" "$root/.local/share/kwalletd" "$root/run"
}

mg_ensure_isolated_dir() {
  local dir=$1
  if [[ -L "$dir" ]]; then
    rm -- "$dir"
  fi
  mkdir -p -- "$dir"
  chmod 700 -- "$dir"
}

mg_isolate_auth_state() {
  local profile=$1
  mg_ensure_isolated_dir "$profile/.antigravitycli"
  mg_ensure_isolated_dir "$profile/.local/share/keyrings"
  mg_ensure_isolated_dir "$profile/.local/share/kwalletd"
  mg_ensure_isolated_dir "$profile/run"
}

mg_link_host_entries() {
  local source=$1 target=$2 entry name excluded
  shift 2
  [[ -d "$source" ]] || return 0
  mkdir -p -- "$target"

  shopt -s dotglob nullglob
  for entry in "$source"/*; do
    name=${entry##*/}
    for excluded in "$@"; do
      [[ "$name" == "$excluded" ]] && continue 2
    done
    [[ -e "$target/$name" || -L "$target/$name" ]] || ln -s -- "$entry" "$target/$name"
  done
}

mg_share_host_state() (
  local profile=$1 entry resolved

  shopt -s dotglob nullglob
  for entry in "$MG_REAL_HOME"/*; do
    case ${entry##*/} in
      .antigravity | .antigravitycli | .cache | .config | .gemini | .local | run) continue ;;
    esac
    resolved=$(readlink -f -- "$entry") || continue
    [[ "$resolved" == "$MG_HOME" || "$MG_HOME" == "$resolved"/* ]] && continue
    [[ -e "$profile/${entry##*/}" || -L "$profile/${entry##*/}" ]] || ln -s -- "$entry" "$profile/${entry##*/}"
  done

  mg_link_host_entries "$MG_REAL_HOME/.config" "$profile/.config" Antigravity antigravity
  mg_link_host_entries "$MG_REAL_HOME/.cache" "$profile/.cache" Antigravity antigravity
  mg_link_host_entries "$MG_REAL_HOME/.local" "$profile/.local" share state
  mg_link_host_entries "$MG_REAL_HOME/.local/share" "$profile/.local/share" Antigravity antigravity keyrings kwalletd
  mg_link_host_entries "$MG_REAL_HOME/.local/state" "$profile/.local/state" Antigravity antigravity
  mg_isolate_auth_state "$profile"
)
