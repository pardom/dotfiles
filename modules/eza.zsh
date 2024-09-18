#!/usr/bin/env zsh

# Ensure eza is installed
if ! command -v eza >/dev/null; then
  brew install eza
fi

alias eza="eza --icons --git --header"
alias ls="eza"
alias ll="eza -l"
alias la="eza -a"
alias lt="eza --tree"
alias lla="eza -la"

