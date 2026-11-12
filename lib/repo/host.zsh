# Functions for finding the host a command acts on and checking that it
# exists. The host is either this machine's name or the host that switch
# applied last, which lib/switch/apply.zsh records as a link.

# --- Applied host ------------------------------------------------------------

# switch links the applied host here; the zsh startup files read it.
typeset -gr HOST_LINK=$XDG_CONFIG_HOME/stowaway/host

# Print the applied host's name. Fails if no host is linked, or the link
# points into another repository's hosts/.
function read_applied_host() {
  local target

  if [[ ! -L $HOST_LINK ]]; then
    return 1
  fi

  # Read only this link without following its target, so a link to a deleted
  # host still gives the host's name.
  read_link "$HOST_LINK"
  target=$REPLY

  # The target's directory must be this repository's hosts/.
  if [[ ${target:h:A} != $STOWAWAY_ROOT/hosts ]]; then
    return 1
  fi

  print -r -- ${target:t}
}

# --- Choosing the host -------------------------------------------------------

# Print this machine's name, the default host for `host create`, and for the
# other host commands until a switch applies a host.
# On macOS that's LocalHostName (set in Sharing settings), which doesn't
# change with the network; elsewhere, the short hostname ($HOST up to the
# first dot).
function get_local_host_name() {
  scutil --get LocalHostName 2>/dev/null || print -r -- ${HOST%%.*}
}

# Print the `stowaway host <verb>` command for host $2, for hints. The name
# is left out when it matches the verb's default: this machine's name for
# create, and the host choose_host picks for add and remove.
# Usage: format_host_command <create|add|remove> <host>
function format_host_command() {
  local verb=$1
  local host_name=$2
  local default_name

  if [[ $verb == create ]]; then
    default_name=$(get_local_host_name)
  else
    choose_host
    default_name=$REPLY
  fi

  if [[ $host_name == $default_name ]]; then
    print -r -- "stowaway host $verb"
  else
    print -r -- "stowaway host $verb $host_name"
  fi
}

# Set REPLY to the host: $1 if given, else the applied host, else this
# machine's name.
function choose_host() {
  local given=${1:-}

  if [[ -n $given ]]; then
    REPLY=$given
  elif ! REPLY=$(read_applied_host); then
    REPLY=$(get_local_host_name)
  fi
}

# Exit unless hosts/$1 exists. The error includes the command that creates
# it.
function require_host() {
  local host_name=$1

  # A plain name only, so "../roles/x" can't be used as a host. Commands
  # check a name given as an argument first (require_valid_name), so this
  # catches names from elsewhere: the host link or this machine's name.
  if ! is_valid_name "$host_name"; then
    die "invalid host name '$host_name'"
  fi

  if [[ -d $STOWAWAY_ROOT/hosts/$host_name ]]; then
    return 0
  fi

  {
    print -r -- "error: no host '$host_name' in hosts/"
    print
    print 'Create it with:'
    print
    print -r -- "  $(format_host_command create $host_name)"
  } >&2
  exit 1
}
