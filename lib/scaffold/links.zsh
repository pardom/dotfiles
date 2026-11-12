# Functions for adding roles and modules to a role or host, and for removing
# them.
#
# A target is a "<kind> <name>" pair, such as "role base" or "module git",
# naming a role or module that a link points to.
# The add and remove commands parse their arguments with
# parse_link_args, check the role or host, and call change_links.

# --- Checks ------------------------------------------------------------------

# Exit with a usage error unless every target is a valid name, exists (when
# adding), and isn't the role or host itself.
# Usage: _require_valid_targets <usage> <add|remove> <kind> <name> <target>...
function _require_valid_targets() {
  local usage=$1
  local action=$2
  local kind=$3
  local name=$4
  local target
  local target_kind
  local target_name
  local target_label

  shift 4

  for target in "$@"; do
    target_kind=${target% *}
    target_name=${target#* }
    target_label="--$target_kind <${target_kind:u}>"

    if [[ $action == add ]]; then
      require_existing_item "$usage" "$target_kind" "$target_name" \
        "$target_label"
    else
      # Removal must also work after the target has been deleted.
      require_valid_name "$usage" "$target_name" "$target_label"
    fi

    if [[ $target_kind == $kind && $target_name == $name ]]; then
      die_invalid_value "$usage" "$target_name" "$target_label" \
        "a $kind can't include itself"
    fi
  done
}

# Succeed if the link at path $1 points to path $2.
function _is_link_to() {
  local link_path=$1
  local target_path=$2

  [[ -L $link_path ]] || return 1
  read_link "$link_path" || return 1
  [[ $REPLY == "$target_path" ]]
}

# Exit unless every target can be linked into the role or host: no two
# targets share a link name, and nothing else is already in the way.
# Usage: _require_linkable_targets <usage> <kind> <name> <target>...
function _require_linkable_targets() {
  local usage=$1
  local kind=$2
  local name=$3
  local link_dir=$STOWAWAY_ROOT/${kind}s/$name
  local target
  local target_kind
  local target_name
  local link_path
  local message
  local -a seen

  shift 3

  for target in "$@"; do
    target_kind=${target% *}
    target_name=${target#* }

    if (( ${seen[(Ie)$target_name]} )); then
      message="a role and a module are both named '$target_name';"
      message+=" a $kind can't hold both"
      die_usage "$usage" "$message"
    fi
    seen+=("$target_name")

    link_path=$link_dir/$target_name
    if _is_link_to "$link_path" \
      "$STOWAWAY_ROOT/${target_kind}s/$target_name"; then
      continue
    fi
    if [[ -e $link_path || -L $link_path ]]; then
      message="${kind}s/$name/$target_name already exists"
      message+=" and isn't a link to ${target_kind}s/$target_name"
      die "$message"
    fi
  done
}

# --- Changes -----------------------------------------------------------------

# Add or remove the link to one target in directory $2. Succeeds if anything
# changed; fails if it was already that way.
# Usage: _change_link <add|remove> <dir> <target kind> <target name>
function _change_link() {
  local action=$1
  local link_dir=$2
  local target_kind=$3
  local target_name=$4
  local -a links

  find_links_to "$STOWAWAY_ROOT/${target_kind}s/$target_name" "$link_dir"/*(N@)
  links=("${reply[@]}")

  if [[ $action == add ]]; then
    (( ${#links} == 0 )) || return 1
    # -n: don't follow an existing link at the destination into its target.
    ln -sn "../../${target_kind}s/$target_name" "$link_dir/$target_name" \
      || die "could not add $target_kind '$target_name' to $link_dir"
  else
    (( ${#links} > 0 )) || return 1
    rm -- "${links[@]}" \
      || die "could not remove $target_kind '$target_name' from $link_dir"
  fi
}

# Print what happened to one target.
# Usage: _print_change <add|remove> <kind> <name> <target kind>
#          <target name> <changed: 0|1>
function _print_change() {
  local action=$1
  local kind=$2
  local name=$3
  local target_kind=$4
  local target_name=$5
  local changed=$6
  local target="$target_kind '$target_name'"

  case $action:$changed in
    add:1)    print -r -- "Added $target to $kind '$name'" ;;
    remove:1) print -r -- "Removed $target from $kind '$name'" ;;
    add:0)    print -r -- "${(C)kind} '$name' already has $target" ;;
    remove:0) print -r -- "${(C)kind} '$name' doesn't have $target" ;;
  esac
}

# --- Entry points ------------------------------------------------------------

# Set REPLY to NAME (empty if not given) and `reply` to the targets, the
# roles before the modules, parsed from the "[OPTIONS] [NAME]" arguments of
# the add and remove commands. The options are -r/--role and -m/--module
# (repeatable, as "--role x" or "--role=x") and -h/--help. Exits after -h, or
# with a usage error. $1 is the command's help function, which -h calls; $2
# its usage line.
# Usage: parse_link_args <help function> <usage> [args...]
function parse_link_args() {
  local help_function=$1
  local usage=$2
  local name=
  local target_name
  local -a role_names
  # Not "modules": zsh reserves that name.
  local -a module_names

  shift 2

  while (( $# > 0 )); do
    case $1 in
      -h|--help)
        $help_function
        exit 0
        ;;
      -r|--role)
        has_option_value "$@" || die_missing_value "$usage" '--role <ROLE>'
        role_names+=($2)
        shift 2
        ;;
      --role=*)
        [[ -n ${1#*=} ]] || die_missing_value "$usage" '--role <ROLE>'
        role_names+=(${1#*=})
        shift
        ;;
      -m|--module)
        has_option_value "$@" || die_missing_value "$usage" '--module <MODULE>'
        module_names+=($2)
        shift 2
        ;;
      --module=*)
        [[ -n ${1#*=} ]] || die_missing_value "$usage" '--module <MODULE>'
        module_names+=(${1#*=})
        shift
        ;;
      -*)
        die_unexpected_argument "$usage" "$1"
        ;;
      *)
        [[ -z $name ]] || die_unexpected_argument "$usage" "$1"
        name=$1
        shift
        ;;
    esac
  done

  REPLY=$name
  reply=()
  for target_name in $role_names; do
    reply+=("role $target_name")
  done
  for target_name in $module_names; do
    reply+=("module $target_name")
  done
}

# Add or remove links to the targets in roles/<name> or hosts/<name>, then
# print what changed. The role or host must exist; check it with
# require_existing_item first. At least one target is required; targets
# repeated on the command line count once.
# Usage: change_links <usage> <add|remove> <role|host> <name> <target>...
function change_links() {
  local usage=$1
  local action=$2
  local kind=$3
  local name=$4
  local link_dir=$STOWAWAY_ROOT/${kind}s/$name
  local target
  local -i changed
  local -i any_changed=0
  local -a targets

  shift 4
  if (( $# == 0 )); then
    die_missing_argument "$usage" '<--role <ROLE>|--module <MODULE>>'
  fi
  targets=("${(u)@}")

  _require_valid_targets "$usage" "$action" "$kind" "$name" "${targets[@]}"
  if [[ $action == add ]]; then
    _require_linkable_targets "$usage" "$kind" "$name" "${targets[@]}"
  fi

  for target in "${targets[@]}"; do
    changed=0
    if _change_link "$action" "$link_dir" ${target% *} ${target#* }; then
      changed=1
      any_changed=1
    fi
    _print_change "$action" "$kind" "$name" \
      ${target% *} ${target#* } $changed
  done

  if (( any_changed )); then
    print_apply_hint
  fi
}
