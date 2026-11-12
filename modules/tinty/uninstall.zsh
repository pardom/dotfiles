#!/bin/zsh -f
set -eu

source "${0:A:h:h:h}/lib/pkg.zsh"

brew_uninstall tinted-theming/tinted/tinty
