#!/usr/bin/env zsh

# Ensure tmux is installed
if ! command -v tmux >/dev/null; then
  brew install tmux
fi

alias tml='tmux list-sessions'
alias tma='tmux new -As $(pwd | sed "s/.*\///g")'
alias tmk='tmux list-sessions -F "#S" | fzf --height ~100% | xargs tmux kill-session -t '

