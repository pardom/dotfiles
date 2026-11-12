# Make the antidote shell function available without downloading plugins.
if [[ -r $ANTIDOTE_SCRIPT ]]; then
  source "$ANTIDOTE_SCRIPT"
fi

# Load only installed plugins; bundle.zsh generates this file.
if [[ -r $ANTIDOTE_PLUGINS ]]; then
  source "$ANTIDOTE_PLUGINS"
fi
