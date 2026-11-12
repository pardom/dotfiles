#!/bin/zsh -f
# Remove roles and modules from a host: removes the links to each from
# hosts/<name>.

set -eu

source $STOWAWAY_ROOT/lib/scaffold.zsh

readonly USAGE='Usage: stowaway host remove [OPTIONS] [NAME]'

function print_help() {
  cat <<EOF
Remove roles and modules from a host

$USAGE

Arguments:
  [NAME]  Host in hosts/ [default: linked host, else this machine's name]

Options:
  -r, --role <ROLE>      Remove a role; repeat for more
  -m, --module <MODULE>  Remove a module; repeat for more
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

  change_links "$USAGE" remove host "$name" "${targets[@]}"
}

main "$@"
