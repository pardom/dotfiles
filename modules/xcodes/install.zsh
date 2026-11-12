#!/bin/zsh -f
set -eu

source "${0:A:h:h:h}/lib/pkg.zsh"

# aria2 speeds up xcodes downloads.
brew_install xcodes aria2
completion_install _xcodes xcodes --generate-completion-script zsh
