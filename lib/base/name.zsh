# The rule for host, role and module names. A name must be a plain directory
# name, so that it can't point outside hosts/, roles/ or modules/
# ("../roles/x") or be mistaken for an option ("-x").

# The rule in words, for error messages.
typeset -gr NAME_RULE="use letters, digits, '.', '_' or '-',\
 not starting with '.' or '-'"

# Succeed if $1 is a valid name.
function is_valid_name() {
  local value=$1

  [[ $value =~ '^[A-Za-z0-9_][A-Za-z0-9._-]*$' ]]
}

# Exit with a usage error unless $2 is a valid name. $1 is the command's
# usage line, $3 the argument's label, e.g. <NAME>.
function require_valid_name() {
  local usage=$1
  local value=$2
  local label=$3

  if ! is_valid_name "$value"; then
    die_invalid_value "$usage" "$value" "$label" "$NAME_RULE"
  fi
}
