if ! command -v fzf >/dev/null 2>&1; then
  return 0
fi

export FZF_DEFAULT_OPTS='--color=16'
source <(fzf --zsh)
