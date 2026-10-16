#!/usr/bin/env zsh
set -e

module_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
source "$module_dir/env.zsh"
source "$ANTIDOTE_DIR/antidote.zsh"

# Regenerate explicitly during install and update, never during shell startup.
bundle_file=$(mktemp "$ANTIDOTE_DIR/plugins.zsh.XXXXXX")
trap 'rm -f -- "$bundle_file"' EXIT
antidote bundle < "$module_dir/plugins.txt" > "$bundle_file"
mv -- "$bundle_file" "$ANTIDOTE_DIR/plugins.zsh"
