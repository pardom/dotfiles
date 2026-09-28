#!/usr/bin/env zsh
set -eu

if ! command -v brew >/dev/null 2>&1; then
    printf '%s\n' 'Install Homebrew and make brew available on PATH before updating Homebrew packages.' >&2
    exit 1
fi

# Upgrades every formula and cask, including those installed by other modules.
brew update
brew upgrade
