#!/bin/zsh -f
set -eu

source "${0:A:h:h:h}/lib/pkg.zsh"

# Packages only: toolchains in $RUSTUP_HOME stay.
brew_uninstall rustup
