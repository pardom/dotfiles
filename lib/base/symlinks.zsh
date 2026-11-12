# Functions for reading symbolic links. They read a link's target without
# following it any further, so a link to a deleted directory still reports
# that directory's name.
#
# Both functions return through REPLY or `reply` rather than printing, and
# read links with the zstat builtin rather than readlink, so callers don't
# start a subshell for each link.

zmodload -F zsh/stat b:zstat

# Set REPLY to the absolute path link $1 points to, without following any
# further links.
function read_link() {
  emulate -L zsh

  local link_path=$1
  local -a target

  # +link gives an empty target for anything that isn't a link.
  zstat -A target +link -- "$link_path" || return 1
  [[ -n ${target[1]} ]] || return 1
  REPLY=${target[1]}
  if [[ $REPLY != /* ]]; then
    # Relative targets are relative to the link's (resolved) directory.
    REPLY=${link_path:h:A}/$REPLY
  fi
  # :a makes it absolute and drops . and .. parts.
  REPLY=${REPLY:a}
}

# Set `reply` to the links, among the rest of the arguments, that point at
# path $1.
# Usage: find_links_to <path> <link>...
function find_links_to() {
  emulate -L zsh

  local target_path=$1
  local link_path

  shift
  reply=()

  for link_path in "$@"; do
    read_link "$link_path" || return 1
    if [[ $REPLY == "$target_path" ]]; then
      reply+=("$link_path")
    fi
  done
}
