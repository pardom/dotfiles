# Dotfiles

## Setup

Install [Homebrew](https://brew.sh) and ensure `brew` is on your PATH.

```zsh
brew install git stow
git clone https://github.com/pardom/dotfiles.git "$HOME/.dotfiles"
zsh "$HOME/.dotfiles/bootstrap.zsh"
```

Back up any existing files that conflict with these configs, then preview and
apply the symlinks:

```zsh
stow --dir="$HOME" --target="$HOME" --simulate --verbose .dotfiles
stow --dir="$HOME" --target="$HOME" .dotfiles
```

If `~/.config/karabiner` already exists, move it to a backup location before
stowing. Karabiner needs the whole directory symlinked; don't use `--no-folding`.

Open a new terminal and initialize the theme:

```zsh
tinty sync
tinty init
```

- Open tmux and press your prefix followed by `I` (capital i) to install plugins.
- Open Neovim to finish its plugin setup.
- Open Karabiner-Elements and complete its macOS setup prompts.
- Run `paneru install` and `paneru start`, then grant Paneru Accessibility access
  in System Settings. Enable “Displays have separate Spaces” in Mission Control.
