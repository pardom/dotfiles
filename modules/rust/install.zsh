#!/usr/bin/env zsh
set -eu

source "$(dirname "$0")/env.zsh"

if [[ -x "$CARGO_HOME/bin/rustup" ]]; then
    exit 0
fi

if ! command -v curl >/dev/null 2>&1; then
    printf '%s\n' 'Install curl before installing rustup.' >&2
    exit 1
fi

installer=$(mktemp "${TMPDIR:-/tmp}/rustup-init.XXXXXX")
trap 'rm -f -- "$installer"' EXIT
curl --proto '=https' --tlsv1.2 -fsSL 'https://sh.rustup.rs' -o "$installer"
# Our env.zsh owns PATH; leave the managed startup files alone.
sh "$installer" -y --no-modify-path --default-toolchain stable

if [[ ! -x "$CARGO_HOME/bin/cargo" ]]; then
    printf '%s\n' 'rustup installation did not create cargo.' >&2
    exit 1
fi
