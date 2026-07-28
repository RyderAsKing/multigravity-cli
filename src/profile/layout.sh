mg_initialize_layout() {
  local root=$1
  mkdir -p -- \
    "$root/.config/Antigravity" \
    "$root/.cache" \
    "$root/.local/share" \
    "$root/.local/state" \
    "$root/.antigravity/extensions"
  chmod 700 -- "$root/.config/Antigravity" "$root/.cache" "$root/.local/share" "$root/.local/state" "$root/.antigravity/extensions"
}
