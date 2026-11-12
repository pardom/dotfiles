#!/bin/zsh -f
set -eu

source "${0:A:h:h:h}/lib/pkg.zsh"

brew_install tpm

# Clone the plugins listed in tpm.conf.
tpm_dir="$HOMEBREW_PREFIX/opt/tpm/share/tpm"
"$tpm_dir/bin/install_plugins"
