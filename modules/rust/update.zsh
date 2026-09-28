#!/usr/bin/env zsh
set -eu

source "$(dirname "$0")/env.zsh"

if [[ ! -x "$CARGO_HOME/bin/rustup" ]]; then
    printf 'rustup is not installed at %s; run install.zsh first.\n' "$CARGO_HOME" >&2
    exit 1
fi

# Updates installed toolchains and rustup itself.
rustup update
