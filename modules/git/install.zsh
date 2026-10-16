#!/usr/bin/env zsh
set -eu

source "${0:A:h:h:h}/scripts/lib/brew.zsh"

# macOS supplies git too; require the Homebrew formula specifically.
brew_install --formula git
