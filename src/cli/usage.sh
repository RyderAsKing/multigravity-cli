mg_usage() {
  cat <<'MG_EOF'
Usage: multigravity COMMAND [ARGUMENTS]

Profile commands:
  new NAME [--shared | --from TEMPLATE]
  launch NAME [-- APP_ARGUMENTS...]
  list [--raw]
  status
  rename OLD NEW
  delete NAME [--yes]
  clone SOURCE DESTINATION
  template save PROFILE NAME
  template list
  template delete NAME [--yes]
  export NAME [OUTPUT] [--force]
  import ARCHIVE [NAME]

Maintenance commands:
  update [--check] [--version vX.Y.Z]
  doctor
  stats
  completion bash|zsh
  version [--short]
  help
MG_EOF
}
