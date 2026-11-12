# Runs last, for interactive shells only: prompt, aliases, completion.

# A shared directory for completion functions that module install scripts
# generate. Added before modules, so a module can still put its own
# directories in front.
fpath=(
  "$XDG_DATA_HOME/zsh/site-functions"
  "${fpath[@]}"
)

# Source each declared module's rc.zsh. The function exists only if .zshenv
# found a host; $+functions[name] is 1 when a function is defined.
if (( ${+functions[list_phase_files]} )); then
  list_phase_files rc
  for STOWAWAY_MODULE_FILE in "${reply[@]}"; do
    source "$STOWAWAY_MODULE_FILE"
  done
  unset STOWAWAY_MODULE_FILE
fi

# Start completion after every module, so the completion directories they
# add to fpath are all seen. Modules install completion functions into
# fpath rather than calling compdef, which needs compinit to have run. The
# dump file, a cache of what compinit found, goes under XDG_CACHE_HOME
# instead of $HOME.
autoload -Uz compinit
[[ -d $XDG_CACHE_HOME/zsh ]] || mkdir -p "$XDG_CACHE_HOME/zsh"
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
