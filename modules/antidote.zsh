#!/usr/bin/env zsh

export ANTIDOTE_DIR="$HOME/.config/antidote"

# Ensure antidote is installed
if [ ! -d "$ANTIDOTE_DIR" ]; then
  git clone --depth=1 https://github.com/mattmc3/antidote.git $ANTIDOTE_DIR
fi

source $ANTIDOTE_DIR/antidote.zsh

antidote load
