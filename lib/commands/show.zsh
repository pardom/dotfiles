#!/bin/zsh -f
# Show a host's roles and modules, and what's available. Prints the host as
# a tree: roles end in /, and each role lists what it adds. A role reached
# twice is expanded once; one that includes itself is marked as a cycle.
# Then lists the modules switch would apply, and the hosts, roles and modules
# in the repository. Changes nothing.

set -eu

source $STOWAWAY_ROOT/lib/repo.zsh

readonly USAGE='Usage: stowaway show [HOST]'

function print_help() {
  cat <<EOF
Show a host's roles and modules, and what's available

$USAGE

Arguments:
  [HOST]  Host in hosts/ [default: linked host, else this machine's name]

Options:
  -h, --help  Print help
EOF
}

# --- Tree --------------------------------------------------------------------

# Set `reply` to (kind name) for link $1, where kind is one of:
#
#   role, module                  the link's target, which exists
#   missing-role, missing-module  the link's target, which was deleted
#   ignored                       the link's own name; switch skips it too
function classify_link() {
  local link_path=$1
  local target
  local kind

  # Follow the whole chain of links if it resolves. Otherwise read only this
  # link, so a link to something deleted still gives its name.
  if [[ -e $link_path ]]; then
    target=${link_path:A}
  else
    read_link "$link_path"
    target=$REPLY
  fi

  case ${target:h} in
    "$STOWAWAY_ROOT/roles")   kind=role ;;
    "$STOWAWAY_ROOT/modules") kind=module ;;
    *)
      reply=(ignored ${link_path:t})
      return 0
      ;;
  esac

  if [[ -d $target ]]; then
    reply=($kind ${target:t})
  else
    reply=(missing-$kind ${target:t})
  fi
}

# Roles already printed in full, across the whole tree, so a role reached
# again prints "(shown above)" instead of repeating its contents.
typeset -ga SHOWN_ROLES

# Print the links in directory $1 as tree lines, each starting with $2. The
# rest of the arguments are the roles being expanded above this level; a role
# among them includes itself.
# Usage: print_tree <dir> <prefix> [open role]...
function print_tree() {
  local tree_dir=$1
  local prefix=$2
  local link_path
  local kind
  local name
  local branch
  local next
  local -i i
  local -a links
  local -a open_roles

  shift 2
  open_roles=("$@")

  links=("$tree_dir"/*(N@on))

  for (( i = 1; i <= ${#links}; i++ )); do
    link_path=${links[i]}

    # The last entry closes the branch; the others continue it.
    if (( i == ${#links} )); then
      branch='└── '
      next='    '
    else
      branch='├── '
      next='│   '
    fi

    classify_link "$link_path"
    kind=${reply[1]}
    name=${reply[2]}

    case $kind in
      role)
        if (( ${open_roles[(Ie)$name]} )); then
          print -r -- "$prefix$branch$name/ (cycle)"
        elif (( ${SHOWN_ROLES[(Ie)$name]} )); then
          print -r -- "$prefix$branch$name/ (shown above)"
        else
          SHOWN_ROLES+=($name)
          print -r -- "$prefix$branch$name/"
          print_tree "$STOWAWAY_ROOT/roles/$name" "$prefix$next" \
            $open_roles $name
        fi
        ;;
      missing-role)   print -r -- "$prefix$branch$name/ (missing)" ;;
      module)         print -r -- "$prefix$branch$name" ;;
      missing-module) print -r -- "$prefix$branch$name (missing)" ;;
      ignored)
        print -r -- "$prefix$branch$name (ignored: not a role or module)"
        ;;
    esac
  done
}

# --- Sections ----------------------------------------------------------------

# Print the host's tree and the modules switch would apply.
function print_active() {
  local host_name=$1
  local host_dir=$STOWAWAY_ROOT/hosts/$host_name
  local -a host_links

  if [[ $(read_applied_host 2>/dev/null) == $host_name ]]; then
    print -r -- "$host_name (applied)"
  else
    print -r -- "$host_name"
  fi

  host_links=("$host_dir"/*(N@))
  if (( ${#host_links} == 0 )); then
    print
    print 'It has no roles or modules yet. Add some with:'
    print
    print -r -- \
      "  $(format_host_command add $host_name) --role <ROLE> --module <MODULE>"
    return 0
  fi

  print_tree "$host_dir" ''

  resolve_host "$host_dir"
  print
  print -r -- "Modules: ${(j:, :)STOWAWAY_MODULES:-none}"
}

# Print "<label> <names>" for the directories in $STOWAWAY_ROOT/$2, or none.
function print_available() {
  local label=$1
  local -a names

  names=("$STOWAWAY_ROOT/$2"/*(N/on:t))
  print -r -- "$label ${(j:, :)names:-none}"
}

# --- Main --------------------------------------------------------------------

function main() {
  local host_arg=
  local host_name

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
  require_host $host_name

  print 'Active'
  print
  print_active $host_name

  print
  print 'Available'
  print
  print_available 'Hosts:  ' hosts
  print_available 'Roles:  ' roles
  print_available 'Modules:' modules
}

main "$@"
