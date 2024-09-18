#!/usr/bin/env zsh

BREW_PATH="/opt/homebrew/bin/brew"

# Ensure homebrew is installed
if [ ! -f "$BREW_PATH" ]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$($BREW_PATH shellenv)"

BREW_PREFIX="$($BREW_PATH --prefix)"

export LIBRARY_PATH="$LIBRARY_PATH:$BREW_PREFIX/lib"
export DYLD_LIBRARY_PATH="$DYLD_LIBRARY_PATH:$BREW_PREFIX/lib"

