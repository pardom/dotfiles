#!/usr/bin/env zsh

# Skip under Claude Code: claude snapshots the post-init env, so zoxide's
# cd=z alias and DB writes would persist into every agent shell.
[[ -n "$CLAUDECODE" ]] && return

# Ensure zoxide is installed
if ! command -v zoxide >/dev/null; then
  brew install zoxide
fi

alias cd="z"

eval "$(zoxide init zsh)"

