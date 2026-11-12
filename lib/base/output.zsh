# Output helpers for the commands: step headings and fatal errors.

# Print a section heading: "==> Links".
function print_step() {
  local title=$1

  printf '\n==> %s\n' "$title"
}

# Exit 1 with error message $1. Phase files are sourced, so this exits the
# whole run, not just the calling function.
function die() {
  local message=$1

  printf 'error: %s\n' "$message" >&2
  exit 1
}
