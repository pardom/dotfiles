#!/usr/bin/env zsh

# Ensure direnv is installed
if ! command -v direnv >/dev/null; then
  brew install direnv
fi

eval "$(direnv hook zsh)"
