#!/usr/bin/env zsh

# Ensure neovim is installed
if ! command -v nvim >/dev/null; then
  brew install neovim
fi

alias vim="nvim"
alias vi="nvim"
alias view="nvim -R"

export NVIM_APPNAME="lazyvim"
export EDITOR=nvim

