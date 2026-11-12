if ! command -v starship >/dev/null 2>&1; then
  return 0
fi

export STARSHIP_CONFIG="$HOME/.config/starship/config.toml"
eval "$(starship init zsh)"
