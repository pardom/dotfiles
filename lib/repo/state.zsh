# Reads and writes the record of modules that switch has installed. switch
# keeps this record so that the next switch can uninstall the modules the
# host no longer uses. `module delete` reads it to refuse deleting a module
# that is still applied. The zsh startup files never read this record, since
# they follow the links directly.

typeset -gr INSTALLED_FILE=$XDG_STATE_HOME/stowaway/installed

# Set `reply` to the recorded modules; empty if none.
function read_installed() {
  reply=()

  if [[ -r $INSTALLED_FILE ]]; then
    reply=(${(f)"$(<$INSTALLED_FILE)"})
  fi
}

# Record the given modules, sorted, replacing what was recorded.
# Usage: write_installed <module>...
function write_installed() {
  local temporary_file

  mkdir -p "${INSTALLED_FILE:h}" || return 1
  temporary_file=$(mktemp "$INSTALLED_FILE.XXXXXXXXXX") || return 1

  if ! print -rl -- "${(@o)@}" > "$temporary_file"; then
    rm -f -- "$temporary_file"
    return 1
  fi

  if ! mv -f -- "$temporary_file" "$INSTALLED_FILE"; then
    rm -f -- "$temporary_file"
    return 1
  fi
}
