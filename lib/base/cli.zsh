# Usage errors for stowaway and its commands. Each command parses its own
# arguments with a case loop and passes its "Usage: ..." line to these. In
# usage lines, [ARG] is optional, <ARG> is required, and [OPTIONS] stands for
# any options.
#
#   error: unexpected argument '--bogus' found
#
#   Usage: stowaway role add [OPTIONS] <NAME>
#
#   For more information, try '--help'.

# Exit 2 with a usage error. $1 is the command's "Usage: ..." line; $2 the
# message, which may span lines.
function die_usage() {
  local usage=$1
  local message=$2

  {
    printf 'error: %s\n\n' "$message"
    print -r -- "$usage"
    printf "\nFor more information, try '--help'.\n"
  } >&2
  exit 2
}

# Exit with a usage error saying argument $2 wasn't expected. $1 is the
# usage line.
function die_unexpected_argument() {
  local usage=$1
  local argument=$2

  die_usage "$usage" "unexpected argument '$argument' found"
}

# Exit with a usage error saying required argument $2 is missing. $1 is the
# usage line.
function die_missing_argument() {
  local usage=$1
  local argument=$2

  die_usage "$usage" \
    "the following required arguments were not provided:"$'\n'"  $argument"
}

# Exit with a usage error saying value $2 for argument label $3 (e.g.
# <NAME>) is invalid; $4 says why. $1 is the usage line.
function die_invalid_value() {
  local usage=$1
  local value=$2
  local label=$3
  local reason=$4

  die_usage "$usage" "invalid value '$value' for '$label': $reason"
}

# Exit with a usage error saying option $2 (e.g. '--role <ROLE>') got no
# value. $1 is the usage line.
function die_missing_value() {
  local usage=$1
  local option=$2

  die_usage "$usage" "a value is required for '$option' but none was supplied"
}

# Succeed if the option in $1 is followed by a value: a non-empty word that
# isn't another option. Pass the command's remaining arguments.
# Usage: has_option_value "$@"
function has_option_value() {
  (( $# > 1 )) && [[ -n $2 && $2 != -* ]]
}
