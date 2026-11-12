#!/bin/zsh -f
# Delete a role: deletes roles/<name> and removes it from every host and role
# that has it. The modules it had stay.

set -eu

source $STOWAWAY_ROOT/lib/scaffold.zsh

readonly USAGE='Usage: stowaway role delete [OPTIONS] <NAME>'

function print_help() {
  cat <<EOF
Delete a role

$USAGE

Arguments:
  <NAME>  Role in roles/

Options:
  -y, --yes   Don't ask for confirmation
  -h, --help  Print help
EOF
}

function main() {
  local name=
  local -i yes=0
  local -a links

  while (( $# > 0 )); do
    case $1 in
      -h|--help)
        print_help
        exit 0
        ;;
      -y|--yes)
        yes=1
        shift
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
  require_existing_item "$USAGE" role "$name" '<NAME>'

  find_item_links role "$name"
  links=("${reply[@]}")

  if (( ! yes )); then
    confirm_delete "$USAGE" role "$name" '' "${links[@]}"
  fi
  delete_item role "$name" "${links[@]}"

  if (( ${#links} > 0 )); then
    print_apply_hint
  fi
}

main "$@"
