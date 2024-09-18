#!/usr/bin/env zsh

# Ensure zoxide is installed
if ! command -v zoxide >/dev/null; then
  brew install zoxide
fi

alias cd="z"

eval "$(zoxide init zsh)"

