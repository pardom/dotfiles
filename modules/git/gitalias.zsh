#!/usr/bin/env zsh
# Downloads GitAlias, replacing any existing copy only after validation.
set -eu

if ! command -v curl >/dev/null 2>&1; then
    printf '%s\n' 'Install curl before downloading GitAlias.' >&2
    exit 1
fi

alias_dir="$HOME/.config/gitalias"
alias_file="$alias_dir/gitalias.txt"
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
