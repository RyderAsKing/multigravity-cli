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

mg_initialize_shared_layout() {
  local root=$1 data_target extensions_target
  data_target=$(mg_system_data_path)
  extensions_target=$(mg_system_extensions_path)
  mkdir -p -- "$data_target" "$extensions_target"
  mkdir -p -- "$root/.config" "$root/.antigravity" "$root/.cache" "$root/.local/share" "$root/.local/state"
  chmod 700 -- "$root/.config" "$root/.antigravity" "$root/.cache" "$root/.local/share" "$root/.local/state"
  ln -s -- "$data_target" "$root/.config/Antigravity"
  ln -s -- "$extensions_target" "$root/.antigravity/extensions"
  : >"$root/.shared"
}

mg_tree_has_untrusted_links() {
  local root=$1 relative
  while IFS= read -r -d '' relative; do
    relative=${relative#"$root/"}
    if [[ -f "$root/.shared" && ("$relative" == '.config/Antigravity' || "$relative" == '.antigravity/extensions') ]]; then
      continue
    fi
    return 0
  done < <(find "$root" -type l -print0)
  return 1
}

mg_copy_profile_tree() {
  local source=$1 destination=$2 shared=0
  mg_tree_has_untrusted_links "$source" && mg_unsafe 'source contains an untrusted symbolic link'
  [[ -f "$source/.shared" ]] && shared=1
  mkdir -p -- "$destination"
  cp -a --no-dereference -- "$source/." "$destination/"
  if ((shared)); then
    rm -f -- "$destination/.config/Antigravity" "$destination/.antigravity/extensions"
    ln -s -- "$(mg_system_data_path)" "$destination/.config/Antigravity"
    ln -s -- "$(mg_system_extensions_path)" "$destination/.antigravity/extensions"
  fi
}
