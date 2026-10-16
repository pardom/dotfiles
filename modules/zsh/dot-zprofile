# Use ~/.dotfiles unless DOTFILES_DIR is already set.
# (N) makes an unmatched pattern an empty list, so missing files are fine.
for module_file in "${DOTFILES_DIR:-$HOME/.dotfiles}"/modules/*/profile.zsh(N); do
    source "$module_file"
done
unset module_file
