#!/bin/sh

echo "==> Setting up environment..."

if ! [ -x "$(command -v brew)" ]; then
	echo "==> Installing Homebrew..."
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

if ! [ -x "$(command -v bash)" ]; then
	echo "==> Installing Bash..."
	brew install bash
fi

if [ -z "$(brew ls --versions bash-completion)" ]; then
	echo "==> Installing bash-completion..."
	brew install bash-completion
fi

if ! [ -x "$(command -v fzf)" ]; then
	echo "==> Installing fzf..."
	brew install fzf
fi

if ! [ -x "$(command -v git)" ]; then
	echo "==> Installing Git..."
	brew install git
fi

if ! [ -x "$(command -v gradle)" ]; then
	echo "==> Installing Gradle..."
	brew install gradle
fi

if ! [ -x "$(command -v vim)" ]; then
	echo "==> Installing Vim..."
	brew install vim
fi

if ! [ -x "$(command -v base16-manager)" ]; then
	echo "==> Installing base16-manager..."
	brew install chrokh/tap/base16-manager
fi

if [ -z "$(base16-manager list | grep chriskempson/base16-shell)" ]; then
	echo "==> Installing base16-manager chriskempson/base16-shell..."
	base16-manager install chriskempson/base16-shell
fi

if [ -z "$(base16-manager list | grep chriskempson/base16-vim)" ]; then
	echo "==> Installing base16-manager chriskempson/base16-vim..."
	base16-manager install chriskempson/base16-vim
fi

if [ -z "$(base16-manager list | grep nicodebo/base16-fzf)" ]; then
	echo "==> Installing base16-manager nicodebo/base16-fzf..."
	base16-manager install nicodebo/base16-fzf
fi

echo "==> Setting base16-manager theme..."
base16-manager set onedark

if ! [ -x "$(command -v chunkwm)" ]; then
	echo "==> Installing chunkwm..."
	brew install koekeishiya/formulae/chunkwm
	echo "==> Configuring chunkwm..."
	ln -s $(brew --prefix chunkwm)/share/chunkwm/plugins/ $HOME/.chunkwm_plugins
	echo "==> Restarting chunkwm..."
	brew services restart chunkwm
fi

if ! [ -x "$(command -v khd)" ]; then
	echo "==> Installing khd..."
	brew install koekeishiya/formulae/khd
	echo "==> Restarting khd..."
	brew services restart khd
fi

echo "==> Finished!"
