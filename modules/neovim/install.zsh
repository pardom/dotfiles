#!/usr/bin/env zsh
set -eu

# Share the app name with runtime configuration.
source "$(dirname "$0")/env.zsh"

if ! command -v nvim >/dev/null 2>&1; then
    if ! command -v brew >/dev/null 2>&1; then
        printf '%s\n' 'Install Homebrew and make brew available on PATH before installing Neovim.' >&2
        exit 1
    fi
    brew install neovim
fi

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
