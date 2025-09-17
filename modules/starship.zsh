#!/usr/bin/env zsh

# Ensure oh-my-posh is installed
if ! command -v starship >/dev/null; then
  brew install starship
fi

export STARSHIP_CONFIG="$HOME/.starship/config.toml"

eval "$(starship init zsh)"

