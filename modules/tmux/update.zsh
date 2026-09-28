#!/usr/bin/env zsh
set -eu

# Keep this location in sync with modules/tmux/install.zsh.
tpm_dir="$HOME/.tmux/plugins/tpm"
if [[ ! -f "$tpm_dir/tpm" ]]; then
    printf 'TPM is not installed at %s; run install.zsh first.\n' "$tpm_dir" >&2
    exit 1
fi

# tmux is a Homebrew formula; TPM and its plugins are git checkouts.
git -C "$tpm_dir" pull --ff-only
"$tpm_dir/bin/update_plugins" all
