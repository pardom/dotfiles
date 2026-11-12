# Shared by the `create`, `delete`, `add` and `remove` commands: checks,
# creating directories, and the apply hint. Each command parses its own
# arguments and passes the results in.
#
# Links point down only: a host adds roles and modules, a role adds roles
# (inheritance) and modules, a module adds nothing.

# --- Checks ------------------------------------------------------------------

# Exit with a usage error unless $3 names an existing <kind> (module, role
# or host). $1 is the usage line, $2 the kind, $4 the argument's label.
function require_existing_item() {
  local usage=$1
  local kind=$2
  local value=$3
  local label=$4

  require_valid_name "$usage" "$value" "$label"
  if [[ ! -d $STOWAWAY_ROOT/${kind}s/$value ]]; then
    die_invalid_value "$usage" "$value" "$label" "no ${kind}s/$value"
  fi
}

# Set REPLY to the host a host command acts on, and exit unless it exists.
# That's $2 if given, checked as an argument with label [NAME]; otherwise
# the host choose_host picks. $1 is the usage line.
# Usage: choose_existing_host <usage> [name]
function choose_existing_host() {
  local usage=$1
  local given=${2:-}

  if [[ -n $given ]]; then
    require_existing_item "$usage" host "$given" '[NAME]'
    REPLY=$given
  else
    choose_host
    require_host "$REPLY"
  fi
}

# Exit if anything exists at repository path $1 (e.g. roles/web).
function require_free_path() {
  local rel_path=$1

  # -e misses broken links; -L catches them.
  if [[ -e $STOWAWAY_ROOT/$rel_path || -L $STOWAWAY_ROOT/$rel_path ]]; then
    die "$rel_path already exists"
  fi
}

# --- Creating ----------------------------------------------------------------

# Create ${kind}s/<name>, and ${kind}s/ itself if needed. Exits if anything
# is already there.
# Usage: create_item_directory <module|role|host> <name>
function create_item_directory() {
  local kind=$1
  local name=$2
  local parent_dir=$STOWAWAY_ROOT/${kind}s

  require_free_path "${kind}s/$name"
  mkdir -p "$parent_dir" || die "could not create ${kind}s/"
  mkdir "$parent_dir/$name" || die "could not create ${kind}s/$name"
}

# Create an empty roles/<name> or hosts/<name> and print the command that
# adds to it. The directory holds an empty .keep file, because git doesn't
# track empty directories and an empty host is valid. Everything that reads
# hosts and roles looks only at symbolic links, so .keep is ignored.
# Usage: create_item <role|host> <name> <add command>
function create_item() {
  local kind=$1
  local name=$2
  local add_command=$3

  create_item_directory "$kind" "$name"
  : > "$STOWAWAY_ROOT/${kind}s/$name/.keep" \
    || die "could not create ${kind}s/$name/.keep"

  print -r -- "Created ${kind}s/$name"
  print
  print 'Add roles and modules to it:'
  print
  print -r -- "  $add_command --role <ROLE> --module <MODULE>"
}

# --- Output ------------------------------------------------------------------

# Print the reminder that changes take effect on the next switch.
function print_apply_hint() {
  print
  print "Run 'stowaway switch' to apply."
}
