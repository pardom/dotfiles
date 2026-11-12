# Runs second, for login shells only (a new terminal window, ssh).

# Source each declared module's profile.zsh. The function exists only if
# .zshenv found a host; $+functions[name] is 1 when a function is defined.
if (( ${+functions[list_phase_files]} )); then
  list_phase_files profile
  for STOWAWAY_MODULE_FILE in "${reply[@]}"; do
    source "$STOWAWAY_MODULE_FILE"
  done
  unset STOWAWAY_MODULE_FILE
fi
