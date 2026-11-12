# Runs first, for every zsh: interactive shells, scripts, and editors that
# start a shell. Keep it to settings non-interactive programs need.

# XDG Base Directory defaults, available before tool modules load. %x is
# this file (~/.zshenv); :A follows the link to the repository's copy.
source "${${(%):-%x}:A:h}/lib/base/xdg.zsh"

# switch links the applied host directory here. Resolve the host's links
# once; .zprofile and .zshrc reuse the module list it produces.
STOWAWAY_HOST_LINK="$XDG_CONFIG_HOME/stowaway/host"

# -L as well as -d: switch only ever makes a link here, so anything else is
# not a host and is skipped.
if [[ -L "$STOWAWAY_HOST_LINK" && -d "$STOWAWAY_HOST_LINK" ]]; then
  # :A follows the link to hosts/<host>; :h:h moves up to the repository root.
  source "${STOWAWAY_HOST_LINK:A:h:h}/lib/repo/modules.zsh"
  resolve_host "$STOWAWAY_HOST_LINK"

  # Source each module's env.zsh here, not inside a function, so the
  # variables it sets are global.
  list_phase_files env
  for STOWAWAY_MODULE_FILE in "${reply[@]}"; do
    source "$STOWAWAY_MODULE_FILE"
  done
  unset STOWAWAY_MODULE_FILE
fi

unset STOWAWAY_HOST_LINK
