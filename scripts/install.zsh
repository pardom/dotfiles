#!/usr/bin/env zsh
# Run explicitly: zsh /path/to/dotfiles/scripts/install.zsh
set -eu

dotfiles_root=$(CDPATH= cd -P "$(dirname "$0")/.." && pwd)
failed=0
# (N) allows an empty set of installers.
for installer in "$dotfiles_root"/modules/*/install.zsh(N); do
    [ -f "$installer" ] || continue
    module_dir=${installer%/*}
    printf 'Installing %s\n' "${module_dir##*/}"
    # Isolate installers from each other's variables and shell options.
    if zsh -f "$installer"; then
        :
    else
        printf 'Failed to install %s; continuing.\n' "${module_dir##*/}" >&2
        failed=1
    fi
done
exit "$failed"
