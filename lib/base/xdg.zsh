# XDG Base Directory defaults. ${VAR:-default} keeps a value set by a parent
# process.
#
# Both ~/.zshenv and the commands source this file, so switch runs install
# scripts with the same values a configured shell has, even on the first
# switch. The startup files source it on its own, so it must not depend on
# the rest of lib/.

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
export XDG_CONFIG_DIRS="${XDG_CONFIG_DIRS:-/etc/xdg}"
# XDG_RUNTIME_DIR requires session-managed lifetime and permissions; do not
# invent a persistent directory or substitute TMPDIR here.
