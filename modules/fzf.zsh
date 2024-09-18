#!/usr/bin/env zsh

# Ensure fzf is installed
if ! command -v fzf >/dev/null; then
  brew install fzf
fi

export FZF_DEFAULT_OPTS="--color=16"
source <(fzf --zsh)

