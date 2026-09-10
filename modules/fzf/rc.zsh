command -v fzf >/dev/null 2>&1 || return 0

export FZF_DEFAULT_OPTS='--color=16'
source <(fzf --zsh)
