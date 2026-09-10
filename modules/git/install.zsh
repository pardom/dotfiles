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

alias_dir="$HOME/.config/gitalias"
alias_file="$alias_dir/gitalias.txt"
# An existing directory does not guarantee a successful previous download.
if [[ ! -s "$alias_file" ]]; then
    if ! command -v curl >/dev/null 2>&1; then
        printf '%s\n' 'Install curl before downloading GitAlias.' >&2
        exit 1
    fi
    mkdir -p "$alias_dir"
    download_file=$(mktemp "$alias_dir/gitalias.txt.XXXXXX")
    trap 'rm -f -- "$download_file"' EXIT
    curl -fsSL https://raw.githubusercontent.com/GitAlias/gitalias/main/gitalias.txt \
        -o "$download_file"
    if [[ ! -s "$download_file" ]]; then
        printf '%s\n' 'GitAlias download was empty.' >&2
        exit 1
    fi
    git config --file "$download_file" --list >/dev/null
    mv -- "$download_file" "$alias_file"
fi
