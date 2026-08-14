#!/usr/bin/env zsh

# Ensure lazygit is installed
if ! command -v lazygit >/dev/null; then
  brew install lazygit
fi

# lazygit defaults to ~/Library/Application Support on macOS, not ~/.config.
# Point it at the stow-managed config so it lands with every other tool.
export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml"
