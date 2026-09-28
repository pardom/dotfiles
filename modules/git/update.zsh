#!/usr/bin/env zsh
set -eu

# Git and Difftastic are Homebrew formulae, so the homebrew module upgrades them.
zsh -f "$(dirname "$0")/gitalias.zsh"
