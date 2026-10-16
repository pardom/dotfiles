#!/usr/bin/env zsh
# Run explicitly: zsh /path/to/dotfiles/scripts/sync.zsh
set -eu

dotfiles_root=$(CDPATH= cd -P "$(dirname "$0")/.." && pwd)
# (N) allows an empty set of syncs.
for sync in "$dotfiles_root"/modules/*/sync.zsh(N); do
    [ -f "$sync" ] || continue
    module_dir=${sync%/*}
    printf 'Syncing %s\n' "${module_dir##*/}"
    # Isolate syncs from each other's variables and shell options.
    zsh -f "$sync"
done
