#!/usr/bin/env zsh
set -eu

source "${0:A:h:h:h}/scripts/lib/brew.zsh"

# Share the app name with runtime configuration.
source "$(dirname "$0")/env.zsh"

brew_install neovim nvim

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/$NVIM_APPNAME"
if [[ ! -e "$config_dir" && ! -L "$config_dir" ]]; then
    if ! command -v git >/dev/null 2>&1; then
        printf '%s\n' 'Install Git and make git available on PATH before installing the Neovim configuration.' >&2
        exit 1
    fi
    mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}"
    git clone git@github.com:pardom/nvim-lazyvim.git "$config_dir"
elif [[ ! -d "$config_dir" ]]; then
    printf 'Neovim configuration path exists but is not a directory: %s\n' "$config_dir" >&2
    exit 1
fi
