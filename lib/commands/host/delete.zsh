#!/bin/zsh -f
# Delete a host: deletes hosts/<name>. The roles and modules it had stay.

set -eu

source $STOWAWAY_ROOT/lib/scaffold.zsh

readonly USAGE='Usage: stowaway host delete [OPTIONS] <NAME>'

function print_help() {
  cat <<EOF
Delete a host

$USAGE

Arguments:
  <NAME>  Host in hosts/

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
  require_existing_item "$USAGE" host "$name" '<NAME>'

  find_item_links host "$name"
  links=("${reply[@]}")

  if (( ! yes )); then
    confirm_delete "$USAGE" host "$name" '' "${links[@]}"
  fi
  delete_item host "$name" "${links[@]}"

  # switch can't reapply a deleted host, so say how to apply another.
  if [[ $(read_applied_host 2>/dev/null) == $name ]]; then
    print
    print -r -- "'$name' was the applied host." \
      "Run 'stowaway switch <HOST>' to apply another."
  elif (( ${#links} > 0 )); then
    print_apply_hint
  fi
}

main "$@"
