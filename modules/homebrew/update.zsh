#!/usr/bin/env zsh
set -eu

if ! command -v brew >/dev/null 2>&1; then
    printf '%s\n' 'Install Homebrew and make brew available on PATH before updating Homebrew.' >&2
    exit 1
fi

# Update Homebrew and its package metadata; modules own package upgrades.
brew update
