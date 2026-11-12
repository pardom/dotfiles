if ! command -v nvim >/dev/null 2>&1; then
  return 0
fi

alias vim='nvim'
alias vi='nvim'
alias view='nvim -R'
