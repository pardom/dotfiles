#!/bin/zsh -f
# Delete a module: deletes modules/<name> and removes it from every role and
# host. Refuses while the module is applied, since switch can't unlink its
# files or run its uninstall.zsh once the directory is gone.

set -eu

source $STOWAWAY_ROOT/lib/scaffold.zsh

readonly USAGE='Usage: stowaway module delete [OPTIONS] <NAME>'

function print_help() {
  cat <<EOF
Delete a module

$USAGE

Arguments:
  <NAME>  Module in modules/

Options:
  -y, --yes   Don't ask for confirmation
  -h, --help  Print help
EOF
}

# Exit unless the last switch left module $1 out. An applied module has
# files linked into $HOME, which Stow can only unlink while the module
# exists.
function require_unapplied_module() {
  local name=$1

  read_installed
  if (( ${reply[(Ie)$name]} )); then
    {
      print -r -- "error: module '$name' is applied"
      print
      print 'Remove it from its roles and hosts and run '\''stowaway switch'\'','
      print 'which unlinks its files and runs its uninstall.zsh. Then delete it.'
    } >&2
    exit 1
  fi
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
  require_existing_item "$USAGE" module "$name" '<NAME>'
  require_unapplied_module "$name"

  find_item_links module "$name"
  links=("${reply[@]}")

  if (( ! yes )); then
    confirm_delete "$USAGE" module "$name" '' "${links[@]}"
  fi
  delete_item module "$name" "${links[@]}"

  if (( ${#links} > 0 )); then
    print_apply_hint
  fi
}

main "$@"
