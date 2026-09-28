#!/usr/bin/env zsh
# Run explicitly: zsh /path/to/dotfiles/update.zsh
set -eu

dotfiles_root=$(CDPATH= cd -P "$(dirname "$0")" && pwd)
# (N) allows an empty set of updaters.
for updater in "$dotfiles_root"/modules/*/update.zsh(N); do
    [ -f "$updater" ] || continue
    module_dir=${updater%/*}
    printf 'Updating %s\n' "${module_dir##*/}"
    # Isolate updaters from each other's variables and shell options.
    zsh -f "$updater"
done
