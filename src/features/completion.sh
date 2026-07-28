mg_cmd_completion() {
  local shell=${1:-}
  (($# <= 1)) || mg_usage_error 'usage: multigravity completion bash|zsh'
  case $shell in
    bash) printf '%s\n' "$MG_BASH_COMPLETION" ;;
    zsh) printf '%s\n' "$MG_ZSH_COMPLETION" ;;
    '') mg_usage_error 'usage: multigravity completion bash|zsh' ;;
    *) mg_usage_error "unsupported shell: $shell" ;;
  esac
}
