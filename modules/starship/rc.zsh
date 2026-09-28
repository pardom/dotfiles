command -v starship >/dev/null 2>&1 || return 0

export STARSHIP_CONFIG="$HOME/.config/starship/config.toml"
eval "$(starship init zsh)"
