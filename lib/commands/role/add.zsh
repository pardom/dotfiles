#!/bin/zsh -f
# Add roles and modules to a role: links each into roles/<name>. A role can
# include other roles, but not hosts.

set -eu

source $STOWAWAY_ROOT/lib/scaffold.zsh

readonly USAGE='Usage: stowaway role add [OPTIONS] <NAME>'

function print_help() {
  cat <<EOF
Add roles and modules to a role

$USAGE

Arguments:
  <NAME>  Role in roles/

Options:
  -r, --role <ROLE>      Include a role; repeat for more
  -m, --module <MODULE>  Add a module; repeat for more
  -h, --help             Print help
EOF
}

function main() {
  local name
  local -a targets

  parse_link_args print_help "$USAGE" "$@"
  name=$REPLY
  targets=("${reply[@]}")

  [[ -n $name ]] || die_missing_argument "$USAGE" '<NAME>'
  require_existing_item "$USAGE" role "$name" '<NAME>'

  change_links "$USAGE" add role "$name" "${targets[@]}"
}

main "$@"
