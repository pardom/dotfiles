# Make the antidote shell function available without downloading plugins.
if [[ -r "${ANTIDOTE_DIR:-$HOME/.config/antidote}/antidote.zsh" ]]; then
    source "${ANTIDOTE_DIR:-$HOME/.config/antidote}/antidote.zsh"
fi

# Load only installed plugins; bootstrap generates this file.
if [[ -r "${ANTIDOTE_DIR:-$HOME/.config/antidote}/plugins.zsh" ]]; then
    source "${ANTIDOTE_DIR:-$HOME/.config/antidote}/plugins.zsh"
fi
