#!/usr/bin/env zsh
set -eu

if command -v tree-sitter >/dev/null 2>&1; then
    exit 0
fi

if ! command -v brew >/dev/null 2>&1; then
    printf '%s\n' 'Install Homebrew and make brew available on PATH before installing tree-sitter.' >&2
    exit 1
fi

brew install tree-sitter-cli
