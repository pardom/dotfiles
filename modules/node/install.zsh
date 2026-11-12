#!/bin/zsh -f
set -eu

source "${0:A:h:h:h}/lib/pkg.zsh"

brew_install node

# Node does not create the REPL history's parent directory.
mkdir -p "$XDG_STATE_HOME/node"
