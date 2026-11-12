#!/bin/zsh -f
set -eu

source "${0:A:h:h:h}/lib/pkg.zsh"

# difftastic is the diff.external tool in dot-gitconfig.
brew_install git difftastic
