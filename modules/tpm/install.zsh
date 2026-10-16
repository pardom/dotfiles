#!/usr/bin/env zsh
set -eu

# Keep this location in sync with .config/tmux/conf.d/tpm.conf.
tpm_dir="$HOME/.tmux/plugins/tpm"
if [ ! -f "$tpm_dir/tpm" ]; then
    if [ -e "$tpm_dir" ] || [ -L "$tpm_dir" ]; then
        printf 'TPM directory exists but is incomplete: %s\n' "$tpm_dir" >&2
        exit 1
    fi
    if ! command -v git >/dev/null 2>&1; then
        printf '%s\n' 'Install Git and make git available on PATH before installing TPM.' >&2
        exit 1
    fi
    mkdir -p "$HOME/.tmux/plugins"
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
fi
