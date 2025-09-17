#!/usr/bin/env zsh

# Ensure tmux is installed
if ! command -v tmux >/dev/null; then
  brew install tmux
fi

export TPM_DIR="$HOME/.tmux/plugins/tpm"

# Ensure TPM is installed
if [ ! -d "$TPM_DIR" ]; then
  git clone https://github.com/tmux-plugins/tpm $TPM_DIR
fi

