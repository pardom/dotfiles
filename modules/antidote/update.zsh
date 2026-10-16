#!/usr/bin/env zsh
set -e

module_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
source "$module_dir/env.zsh"

if [[ ! -f "$ANTIDOTE_DIR/antidote.zsh" ]]; then
    printf 'Antidote is not installed at %s; run install.zsh first.\n' "$ANTIDOTE_DIR" >&2
    exit 1
fi

source "$ANTIDOTE_DIR/antidote.zsh"
# Updates antidote itself and every cloned bundle.
antidote update
zsh -f "$module_dir/bundle.zsh"
