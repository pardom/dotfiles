#!/usr/bin/env zsh
set -eu

if ! command -v brew >/dev/null 2>&1; then
    printf '%s\n' 'Install Homebrew and make brew available on PATH before installing Git and Difftastic.' >&2
    exit 1
fi

# macOS supplies git too; require the Homebrew formula specifically.
if ! brew list --formula --versions git >/dev/null 2>&1; then
    brew install git
fi

if ! command -v difft >/dev/null 2>&1; then
    brew install difftastic
fi

# An existing directory does not guarantee a successful previous download.
if [[ ! -s "$HOME/.config/gitalias/gitalias.txt" ]]; then
    zsh -f "$(dirname "$0")/gitalias.zsh"
fi
