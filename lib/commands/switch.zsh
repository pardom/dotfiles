#!/bin/zsh -f
# Apply a host's configuration: resolve the modules linked from
# hosts/<host> (through roles), link their files (unlinking the rest), link
# the host to ~/.config/stowaway/host so the shell loads the same modules,
# run uninstall.zsh for modules dropped since the last switch, and run their
# install.zsh.
#
# switch decides everything first (lib/switch/plan.zsh), then previews or
# runs it (lib/switch/apply.zsh).

set -eu

source $STOWAWAY_ROOT/lib/switch.zsh

readonly USAGE='Usage: stowaway switch [OPTIONS] [HOST]'

function print_help() {
  cat <<EOF
Apply a host's configuration

$USAGE

Arguments:
  [HOST]  Host in hosts/ [default: linked host, else this machine's name]

Options:
  -n, --dry-run  Show what would change without changing anything
  -h, --help     Print help
EOF
}

# The oldest Stow version switch is tested with. Earlier versions have bugs
# with --dotfiles when unstowing dot- directories, and every relink (-R)
# unstows first.
readonly MIN_STOW_VERSION=2.4

# Exit unless GNU Stow is on PATH. How it got there is up to the user. Warns
# if it's older than MIN_STOW_VERSION, but runs anyway.
function require_stow() {
  local stow_version

  if ! command -v stow >/dev/null 2>&1; then
    die 'GNU Stow not found on PATH; install it, then run switch again'
  fi

  # "stow (GNU Stow) version 2.4.1" -> "2.4.1". Quoted, so the output stays
  # one word for ##.
  stow_version=${"$(stow --version 2>/dev/null)"##* }
  autoload -Uz is-at-least
  if [[ $stow_version != [0-9]* ]]; then
    printf "warning: couldn't read Stow's version; %s or later is needed\n" \
      $MIN_STOW_VERSION >&2
  elif ! is-at-least $MIN_STOW_VERSION "$stow_version"; then
    printf 'warning: Stow %s is older than %s; unlinking dot- directories may fail\n' \
      "$stow_version" $MIN_STOW_VERSION >&2
  fi
}

# Exit if something other than a link is at the host-link path. ln -sfn
# replaces a link, but it would put the new link inside a directory.
function require_replaceable_host_link() {
  if [[ -e $HOST_LINK && ! -L $HOST_LINK ]]; then
    die "${HOST_LINK/#$HOME/~} isn't a link; move it aside, then run switch again"
  fi
}

function main() {
  local host_arg=
  local -i dry_run=0
  local host_name

  while (( $# > 0 )); do
    case $1 in
      -h|--help)
        print_help
        exit 0
        ;;
      -n|--dry-run)
        dry_run=1
        shift
        ;;
      -*)
        die_unexpected_argument "$USAGE" "$1"
        ;;
      *)
        [[ -z $host_arg ]] || die_unexpected_argument "$USAGE" "$1"
        host_arg=$1
        shift
        ;;
    esac
  done

  if [[ -n $host_arg ]]; then
    require_valid_name "$USAGE" "$host_arg" '[HOST]'
  fi

  choose_host "$host_arg"
  host_name=$REPLY
  require_host "$host_name"
  resolve_host "$STOWAWAY_ROOT/hosts/$host_name"
  require_stow
  require_ignore_policies
  require_replaceable_host_link

  print -r -- "Host:    $host_name"
  print -r -- "Roles:   ${STOWAWAY_ROLES[*]}"
  print -r -- "Modules: ${STOWAWAY_MODULES[*]}"

  plan_switch "$host_name"
  if ! apply_switch $dry_run "${reply[@]}"; then
    exit 1
  fi

  printf '\nDone. Open a new terminal to load the configuration.\n'
}

main "$@"
