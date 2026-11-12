#!/bin/zsh -f
set -eu

source "${0:A:h:h:h}/lib/pkg.zsh"

# Trusted through ~/.config/homebrew/trust.json (homebrew module).
brew_install tinted-theming/tinted/tinty
