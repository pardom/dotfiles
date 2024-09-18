#!/usr/bin/env zsh

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]-_}={[:upper:][:lower:]_-}' 'r:|=*' 'l:|=* r:|=*'

ANTIGEN_PATH="$HOME/.dotfiles/modules/antigen.zsh"

# Ensure antigen exists
if [ ! -e "$ANTIGEN_PATH" ]; then
  curl -fsSL git.io/antigen > $ANTIGEN_PATH
  source modules/antigen.zsh
fi

# Plugins
antigen bundle fdellwing/zsh-bat
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-syntax-highlighting

antigen apply

