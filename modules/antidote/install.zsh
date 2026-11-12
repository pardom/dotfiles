#!/bin/zsh -f
set -eu

source "${0:A:h:h:h}/lib/pkg.zsh"

brew_install antidote

# Clone the plugins in plugins.txt.
zsh -f "${0:A:h}/bundle.zsh"
