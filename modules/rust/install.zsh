#!/bin/zsh -f
set -eu

source "${0:A:h:h:h}/lib/pkg.zsh"
# Sets RUSTUP_HOME and CARGO_HOME, then puts rustup on PATH.
source "${0:A:h}/env.zsh"
source "${0:A:h}/profile.zsh"

brew_install rustup

# Add a default toolchain.
if ! rustup toolchain list | grep -q .; then
  rustup default stable
fi
