#!/bin/zsh -f
set -eu

source "${0:A:h:h:h}/lib/pkg.zsh"

brew_uninstall xcodes aria2
completion_uninstall _xcodes
