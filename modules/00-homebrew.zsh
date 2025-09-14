#!/usr/bin/env zsh

# Ensure homebrew is installed
if ! command -v brew >/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

BREW_PATH="$(command -v brew)"

eval "$($BREW_PATH shellenv)"

BREW_PREFIX="$($BREW_PATH --prefix)"

export LIBRARY_PATH="$LIBRARY_PATH:$BREW_PREFIX/lib"
export DYLD_LIBRARY_PATH="$DYLD_LIBRARY_PATH:$BREW_PREFIX/lib"

