command -v bat >/dev/null 2>&1 || return 0

export BAT_THEME='base16-256'
alias cat='bat --paging=never'
