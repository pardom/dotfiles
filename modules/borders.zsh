#!/usr/bin/env zsh

# Ensure borders is installed
if ! command -v borders >/dev/null; then
  brew install borders
fi

borders \
  style=round \
  width=10.0 \
  hidpi=on \
  active_color=0xFFEB6F92 \
  inactive_color=0x88232136 

