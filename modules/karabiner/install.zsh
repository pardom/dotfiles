#!/usr/bin/env zsh
set -eu

# Karabiner is a macOS app, so detect the app rather than a PATH entry.
if [[ -d /Applications/Karabiner-Elements.app ]]; then
    exit 0
fi

if ! command -v brew >/dev/null 2>&1; then
    printf '%s\n' 'Install Homebrew and make brew available on PATH before installing Karabiner-Elements.' >&2
    exit 1
fi

brew install --cask karabiner-elements
