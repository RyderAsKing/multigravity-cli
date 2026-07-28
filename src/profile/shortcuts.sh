mg_shell_quote() { printf '%q' "$1"; }

mg_desktop_escape() {
  local value=$1
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//\%/%%}
  printf '%s' "$value"
}

mg_prepare_shortcut_dirs() {
  local integration="$MG_DATA_HOME/multigravity" launcher_dir desktop_dir
  launcher_dir=$(mg_launcher_root)
  desktop_dir="$MG_DATA_HOME/applications"
  [[ ! -L "$integration" && ! -L "$launcher_dir" && ! -L "$desktop_dir" ]] || mg_unsafe 'desktop integration directories must not be symbolic links'
  mkdir -p -- "$launcher_dir" "$desktop_dir"
  mg_require_real_directory "$launcher_dir" "$MG_DATA_HOME"
  mg_require_real_directory "$desktop_dir" "$MG_DATA_HOME"
}

mg_create_shortcut() {
  local name=$1 launcher desktop launcher_dir desktop_dir tmp
  launcher=$(mg_launcher_path "$name")
  desktop=$(mg_desktop_path "$name")
  launcher_dir=$(dirname -- "$launcher")
  desktop_dir=$(dirname -- "$desktop")
  mg_prepare_shortcut_dirs

  tmp=$(mktemp -p "$launcher_dir" ".${name}.XXXXXXXX")
  {
    printf '%s\n' '#!/usr/bin/env bash' 'set -euo pipefail'
    printf 'exec %s launch %s -- "$@"\n' "$(mg_shell_quote "$MG_EXECUTABLE")" "$(mg_shell_quote "$name")"
  } >"$tmp"
  chmod 755 "$tmp"
  mv -fT -- "$tmp" "$launcher"

  tmp=$(mktemp -p "$desktop_dir" ".multigravity-${name}.XXXXXXXX")
  {
    printf '%s\n' '[Desktop Entry]' 'Type=Application'
    printf 'Name=Antigravity (%s)\n' "$name"
    printf 'Comment=Launch isolated Antigravity profile %s\n' "$name"
    printf 'Exec="%s"\n' "$(mg_desktop_escape "$launcher")"
    printf '%s\n' 'Terminal=false' 'Categories=Development;IDE;' 'StartupNotify=true'
  } >"$tmp"
  chmod 644 "$tmp"
  mv -fT -- "$tmp" "$desktop"
}

mg_remove_shortcut() {
  local name=$1 launcher desktop
  mg_prepare_shortcut_dirs
  launcher=$(mg_launcher_path "$name")
  desktop=$(mg_desktop_path "$name")
  rm -f -- "$launcher" "$desktop"
}
