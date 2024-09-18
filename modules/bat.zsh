#!/usr/bin/env zsh

# Ensure bat is installed
if ! command -v bat >/dev/null; then
  brew install bat
fi

export BAT_THEME="base16-256"

alias cat='bat --paging=never'

