#!/usr/bin/env zsh

# Ensure oh-my-posh is installed
if ! command -v oh-my-posh >/dev/null; then
  brew install oh-my-posh
fi

eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/config.json)"

