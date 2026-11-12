# Functions for deleting a module, role or host along with the links to it.
#
# A delete command runs the steps in order: find the links (find_item_links),
# ask unless --yes (confirm_delete), then delete (delete_item).

# Print "<kind> '<name>'" for the role or host holding link $1:
# roles/extra/base -> role 'extra'.
function _describe_link_owner() {
  local link_path=$1
  local owner_dir=${link_path:h}
  local owner_kind=${owner_dir:h:t}

  print -r -- "${owner_kind%s} '${owner_dir:t}'"
}

# Set `reply` to the links in roles/ and hosts/ that point at ${kind}s/<name>.
# Usage: find_item_links <module|role|host> <name>
function find_item_links() {
  local kind=$1
  local name=$2

  find_links_to "$STOWAWAY_ROOT/${kind}s/$name" \
    "$STOWAWAY_ROOT"/{roles,hosts}/*/*(N@)
}

# Say what deleting ${kind}s/<name> removes, plus the notice if it isn't
# empty, and ask. Exits 1 unless the answer is yes, or with a usage error if
# there's no terminal to ask on.
# Usage: confirm_delete <usage> <kind> <name> <notice> <link>...
function confirm_delete() {
  local usage=$1
  local kind=$2
  local name=$3
  local notice=$4
  local link_path
  local answer

  shift 4

  if [[ ! -t 0 ]]; then
    die_usage "$usage" \
      "refusing to delete ${kind}s/$name without confirmation; pass --yes"
  fi

  print -r -- "This deletes ${kind}s/$name."
  if (( $# > 0 )); then
    print 'It will also be removed from:'
    for link_path in "$@"; do
      print -r -- "  $(_describe_link_owner "$link_path")"
    done
  fi
  if [[ -n $notice ]]; then
    print -r -- "$notice"
  fi

  print -n 'Delete? [y/N] '
  if ! read -r answer; then
    print
    answer=
  fi
  if [[ $answer != [yY]([eE][sS]|) ]]; then
    print 'Cancelled.'
    exit 1
  fi
}

# Remove the links to ${kind}s/<name>, then the directory itself, printing
# each step.
# Usage: delete_item <module|role|host> <name> <link>...
function delete_item() {
  local kind=$1
  local name=$2
  local link_path

  shift 2

  for link_path in "$@"; do
    rm -- "$link_path" || die "could not remove link $link_path"
    print -r -- \
      "Removed $kind '$name' from $(_describe_link_owner "$link_path")"
  done

  rm -rf -- "$STOWAWAY_ROOT/${kind}s/$name" \
    || die "could not delete ${kind}s/$name"
  print -r -- "Deleted ${kind}s/$name"
}
