#!/usr/bin/env zsh
set -eu

if ! command -v brew >/dev/null 2>&1; then
    printf '%s\n' 'Install Homebrew and make brew available on PATH before installing xcodes.' >&2
    exit 1
fi

if ! brew list --formula --versions xcodesorg/made/xcodes >/dev/null 2>&1; then
    brew install xcodesorg/made/xcodes
fi
