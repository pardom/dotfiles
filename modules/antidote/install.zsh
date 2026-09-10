#!/usr/bin/env zsh
set -e

module_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
source "$module_dir/env.zsh"

if [[ ! -f "$ANTIDOTE_DIR/antidote.zsh" ]]; then
    if [[ -e "$ANTIDOTE_DIR" || -L "$ANTIDOTE_DIR" ]]; then
        printf 'Antidote path exists but is incomplete: %s\n' "$ANTIDOTE_DIR" >&2
        exit 1
    fi
    if ! command -v git >/dev/null 2>&1; then
        printf '%s\n' 'Install Git before installing Antidote.' >&2
        exit 1
    fi
    mkdir -p "$(dirname "$ANTIDOTE_DIR")"
    git clone --depth=1 https://github.com/mattmc3/antidote.git "$ANTIDOTE_DIR"
fi

source "$ANTIDOTE_DIR/antidote.zsh"
# Regenerate explicitly during bootstrap, never during shell startup.
bundle_file=$(mktemp "$ANTIDOTE_DIR/plugins.zsh.XXXXXX")
trap 'rm -f -- "$bundle_file"' EXIT
antidote bundle < "$module_dir/plugins.txt" > "$bundle_file"
mv -- "$bundle_file" "$ANTIDOTE_DIR/plugins.zsh"
