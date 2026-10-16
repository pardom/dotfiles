#!/usr/bin/env zsh
set -eu

source "${0:A:h:h:h}/scripts/lib/brew.zsh"

# npm and npx ship with Node.js; this module's update.zsh upgrades it.
brew_install node npm
