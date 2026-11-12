if ! command -v bat >/dev/null 2>&1; then
  return 0
fi

export BAT_THEME='base16-256'
alias cat='bat --paging=never'
