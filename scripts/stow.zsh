#!/usr/bin/env zsh
# Deploy every module in one transaction; accepts Stow action/preview options.
set -eu

dotfiles_root=${0:A:h:h}
module_dirs=("$dotfiles_root"/modules/*(N/))
packages=()
for module_dir in "${module_dirs[@]}"; do
    # Every package must opt into the common payload-only deployment policy.
    if [[ ! -f "$module_dir/.stow-local-ignore" ]]; then
        printf 'Missing Stow ignore policy: %s/.stow-local-ignore\n' "$module_dir" >&2
        exit 1
    fi
    packages+=("${module_dir:t}")
done
(( ${#packages} )) || { printf 'No modules found\n' >&2; exit 1; }
# Load repository defaults regardless of the caller's working directory.
# Stow may also read ~/.stowrc, as it does for direct invocations.
cd "$dotfiles_root"
exec stow --dir="$dotfiles_root/modules" --target="$HOME" \
    --dotfiles --no-folding "$@" "${packages[@]}"
