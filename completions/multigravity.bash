_multigravity_complete() {
  local cur command profiles
  cur=${COMP_WORDS[COMP_CWORD]}
  command=${COMP_WORDS[1]:-}
  if ((COMP_CWORD == 1)); then
    COMPREPLY=($(compgen -W 'new launch list status rename delete clone template export import update doctor stats completion version help' -- "$cur"))
    return
  fi
  case $command in
    launch|delete|rename|clone|export)
      profiles=$(multigravity list --raw 2>/dev/null)
      COMPREPLY=($(compgen -W "$profiles" -- "$cur"))
      ;;
  esac
}
complete -F _multigravity_complete multigravity
