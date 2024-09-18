#!/usr/bin/env zsh

# Ensure git is installed
if ! command -v git >/dev/null; then
  brew install git
fi

GIT_ALIAS_PATH="$HOME/.config/gitalias/gitalias.txt"

# Ensure gitalias exists
if [ ! -e "$GIT_ALIAS_PATH" ]; then
  curl -fsSL "https://raw.githubusercontent.com/GitAlias/gitalias/refs/heads/main/gitalias.txt" > $GIT_ALIAS_PATH
fi

GIT_INCLUDES=$(git config --global --get-all include.path)
if [[ "$GIT_INCLUDES" != *"$GIT_ALIAS_PATH"* ]]; then
  git config --global --add include.path $GIT_ALIAS_PATH
fi

git config --global user.name "Michael Pardo"
git config --global user.email "mpardo@netflix.com"

git config --global credential.helper "osxkeychain"

git config --global diff.external difft

git config --global diff.tool "Kaleidoscope"
git config --global difftool.Kaleidoscope.cmd "ksdiff --partial-changeset --relative-path \"\$MERGED\" -- \"\$LOCAL\" \"\$REMOTE\""
git config --global difftool.prompt false

git config --global merge.tool "Kaleidoscope"
git config --global mergetool.Kaleidoscope.cmd "ksdiff --merge --output \"\$MERGED\" --base \"\$BASE\" -- \"\$LOCAL\" --snapshot \"\$REMOTE\" --snapshot"
git config --global mergetool.prompt false

