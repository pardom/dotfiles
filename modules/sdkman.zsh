#!/usr/bin/env zsh

export SDKMAN_DIR="$HOME/.sdkman"

# Ensure sdkman is installed
if [ ! -d "$SDKMAN_DIR" ]; then
  curl -fsSL "https://get.sdkman.io" | bash
fi

source "$SDKMAN_DIR/bin/sdkman-init.sh"

