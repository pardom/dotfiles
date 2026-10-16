#!/usr/bin/env zsh
set -eu

# An existing directory does not guarantee a successful previous download.
if [[ ! -s "$HOME/.config/gitalias/gitalias.txt" ]]; then
    zsh -f "${0:A:h}/update.zsh"
fi
