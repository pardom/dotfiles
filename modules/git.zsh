#!/usr/bin/env zsh

# Ensure git is installed
if ! command -v git >/dev/null; then
  brew install git
fi

GIT_ALIAS_DIR="$HOME/.config/gitalias"
GIT_ALIAS_PATH="$GIT_ALIAS_DIR/gitalias.txt"

# Ensure gitalias exists
if [ ! -d "$GIT_ALIAS_DIR" ]; then
  mkdir -p "$GIT_ALIAS_DIR"
  curl -fsSL  "https://raw.githubusercontent.com/GitAlias/gitalias/main/gitalias.txt" > $GIT_ALIAS_PATH
fi

# Append as a fresh [include] section so it lands outside the metatron-managed
# block, which gets rewritten and would otherwise wipe the entry.
GIT_INCLUDES=$(git config --global --get-all include.path 2>/dev/null)
if [[ "$GIT_INCLUDES" != *"$GIT_ALIAS_PATH"* ]]; then
  printf '\n[include]\n\tpath = %s\n' "$GIT_ALIAS_PATH" >> "$HOME/.gitconfig"
fi

git config --global user.name "Michael Pardo"
git config --global user.email "mpardo@netflix.com"
git config --global credential.helper "osxkeychain"
git config --global diff.external difft

