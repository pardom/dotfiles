#!/usr/bin/env zsh

# Ensure fd is installed
if ! command -v fd >/dev/null; then
  brew install fd
fi
