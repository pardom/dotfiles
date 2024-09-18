#!/usr/bin/env zsh

git_alias="$HOME/.config/gitalias/gitalias.txt"
git_includes=$(git config --global --get-all include.path)
if [[ "$git_includes" != *"$git_alias"* ]]; then
  git config --global --add include.path $git_alias
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

