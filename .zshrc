# Antidote adds completion directories, so load it before compinit.
antidote_module="${DOTFILES_DIR:-$HOME/.dotfiles}/modules/antidote/rc.zsh"
if [[ -r "$antidote_module" ]]; then
    source "$antidote_module"
fi

autoload -Uz compinit
compinit

# Use ~/.dotfiles unless DOTFILES_DIR is already set.
# (N) makes an unmatched pattern an empty list, so missing files are fine.
for module_file in "${DOTFILES_DIR:-$HOME/.dotfiles}"/modules/*/rc.zsh(N); do
    [[ "$module_file" = "$antidote_module" ]] && continue
    source "$module_file"
done
unset module_file
unset antidote_module
