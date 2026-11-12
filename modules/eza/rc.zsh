if ! command -v eza >/dev/null 2>&1; then
  return 0
fi

alias eza='eza --icons --git --header'
alias ls='eza'
alias ll='eza -l'
alias la='eza -a'
alias lt='eza --tree'
alias lla='eza -la'
