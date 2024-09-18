#!/usr/bin/env zsh

for module in $HOME/.dotfiles/modules/*.zsh; do
  . "$module"
done

