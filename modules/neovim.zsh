#!/usr/bin/env zsh

# Ensure neovim is installed
if ! command -v nvim >/dev/null; then
  brew install neovim
fi

LAZYVIM_APP_NAME="nvim-lazyvim"
LAZYVIM_PATH="$HOME/.config/$LAZYVIM_APP_NAME"

export NVIM_APPNAME=$LAZYVIM_APP_NAME
export EDITOR=nvim

# Ensure lazyvim is installed
if [ ! -e "$LAZYVIM_PATH" ]; then
  git clone git@github.com:pardom/nvim-lazyvim.git $LAZYVIM_PATH
fi

alias vim="nvim"
alias vi="nvim"
alias view="nvim -R"

