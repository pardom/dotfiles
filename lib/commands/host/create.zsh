#!/bin/zsh -f
# Create a host: a hosts/<name> holding only .keep. The default name is the
# one switch picks when no host is given or linked.

set -eu

source $STOWAWAY_ROOT/lib/scaffold.zsh

readonly USAGE='Usage: stowaway host create [NAME]'

function print_help() {
  cat <<EOF
Create a host

$USAGE

Arguments:
  [NAME]  Host directory to create in hosts/ [default: this machine's name]

Options:
  -h, --help  Print help
EOF
}

function main() {
  local name=

  while (( $# > 0 )); do
    case $1 in
      -h|--help)
        print_help
        exit 0
        ;;
      -*)
        die_unexpected_argument "$USAGE" "$1"
        ;;
      *)
        [[ -z $name ]] || die_unexpected_argument "$USAGE" "$1"
        name=$1
        shift
        ;;
    esac
  done

  name=${name:-$(get_local_host_name)}
  require_valid_name "$USAGE" "$name" '[NAME]'

  create_item host "$name" "$(format_host_command add "$name")"
}

main "$@"
