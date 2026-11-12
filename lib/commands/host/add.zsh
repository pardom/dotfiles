#!/bin/zsh -f
# Add roles and modules to a host: links each into hosts/<name>.

set -eu

source $STOWAWAY_ROOT/lib/scaffold.zsh

readonly USAGE='Usage: stowaway host add [OPTIONS] [NAME]'

function print_help() {
  cat <<EOF
Add roles and modules to a host

$USAGE

Arguments:
  [NAME]  Host in hosts/ [default: linked host, else this machine's name]

Options:
  -r, --role <ROLE>      Add a role; repeat for more
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

  choose_existing_host "$USAGE" "$name"
  name=$REPLY

  change_links "$USAGE" add host "$name" "${targets[@]}"
}

main "$@"
