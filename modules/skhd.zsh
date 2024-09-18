#!/usr/bin/env zsh

# Ensure skhd is installed
if ! command -v skhd >/dev/null; then
  brew install koekeishiya/formulae/skhd
fi
