#!/bin/zsh -f
# Create a role: a roles/<name> holding only .keep. Add roles and modules to
# it with `stowaway role add`.

set -eu

source $STOWAWAY_ROOT/lib/scaffold.zsh

readonly USAGE='Usage: stowaway role create <NAME>'

function print_help() {
  cat <<EOF
Create a role

$USAGE

Arguments:
  <NAME>  Role directory to create in roles/

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

  [[ -n $name ]] || die_missing_argument "$USAGE" '<NAME>'
  require_valid_name "$USAGE" "$name" '<NAME>'

  create_item role "$name" "stowaway role add $name"
}

main "$@"
