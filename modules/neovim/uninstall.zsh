#!/bin/zsh -f
set -eu

source "${0:A:h:h:h}/lib/pkg.zsh"

# Packages only: the cloned configuration in ~/.config/$NVIM_APPNAME stays.
brew_uninstall neovim tree-sitter-cli
