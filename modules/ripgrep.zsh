#!/usr/bin/env zsh

# Ensure ripgrep is installed
if ! command -v rg >/dev/null; then
  brew install ripgrep
fi

