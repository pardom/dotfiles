#!/bin/zsh -f
set -eu

source "${0:A:h:h:h}/lib/pkg.zsh"

cask_install karabiner-elements

# Karabiner only reloads config changes when ~/.config/karabiner, not
# karabiner.json, is the symlink. Stow runs with --no-folding and skips this
# directory (.stow-local-ignore), so link the directory here.

config_source=${0:A:h}/dot-config/karabiner
config_link=$HOME/.config/karabiner

if [[ -L $config_link && ! -e $config_link ]]; then
  # Dangling link (e.g. left over from an old repo layout): safe to replace.
  ln -sfn "$config_source" "$config_link"
elif [[ -L $config_link ]]; then
  if [[ ${config_link:A} != "${config_source:A}" ]]; then
    printf 'warning: %s points to %s, not %s\n' \
      "$config_link" \
      "$(readlink "$config_link")" \
      "$config_source" \
      >&2
  fi
elif [[ -e $config_link ]]; then
  printf 'warning: %s is a real directory; move it aside to link %s\n' \
    "$config_link" \
    "$config_source" \
    >&2
else
  mkdir -p "${config_link:h}"
  ln -s "$config_source" "$config_link"
fi
