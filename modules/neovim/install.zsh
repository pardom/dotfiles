#!/bin/zsh -f
set -eu

source "${0:A:h:h:h}/lib/pkg.zsh"

brew_install neovim tree-sitter-cli

# Share the app name with runtime configuration.
source "${0:A:h}/env.zsh"

config_dir=$XDG_CONFIG_HOME/$NVIM_APPNAME
config_repository='git@github.com:pardom/nvim-lazyvim.git'

# -L also catches a dangling link, which -e misses.
if [[ -e $config_dir || -L $config_dir ]]; then
  if [[ ! -d $config_dir ]]; then
    printf 'error: Neovim configuration path is not a directory: %s\n' \
      "$config_dir" >&2
    exit 1
  fi

  exit 0
fi

if ! command -v git >/dev/null 2>&1; then
  printf 'error: %s\n' 'git is not on PATH; install it first' >&2
  exit 1
fi

mkdir -p "$XDG_CONFIG_HOME"
git clone "$config_repository" "$config_dir"
