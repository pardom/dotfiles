#!/bin/zsh -f
set -eu

source "${0:A:h:h:h}/lib/pkg.zsh"

# Package only: the npm cache, config, and REPL history stay.
brew_uninstall node
