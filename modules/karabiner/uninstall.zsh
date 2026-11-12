#!/bin/zsh -f
set -eu

source "${0:A:h:h:h}/lib/pkg.zsh"

cask_uninstall karabiner-elements

# Remove the directory link install.zsh made, if it still points here.
config_source=${0:A:h}/dot-config/karabiner
config_link=$HOME/.config/karabiner

if [[ -L $config_link && ${config_link:A} == "$config_source" ]]; then
  rm -- "$config_link"
fi
