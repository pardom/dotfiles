#!/usr/bin/env zsh
# Run explicitly: zsh /path/to/dotfiles/bootstrap.zsh
set -eu

dotfiles_root=$(CDPATH= cd -P "$(dirname "$0")" && pwd)
# (N) allows an empty set of installers.
for installer in "$dotfiles_root"/modules/*/install.zsh(N); do
    [ -f "$installer" ] || continue
    module_dir=${installer%/*}
    printf 'Installing %s\n' "${module_dir##*/}"
    # Isolate installers from each other's variables and shell options.
    zsh -f "$installer"
done
