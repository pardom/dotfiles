#!/bin/sh

echo "==> Setting up environment..."

if ! [ -f $HOME/.cfg/HEAD ]; then
    echo "==> Downloading dotfiles..."
    git clone --separate-git-dir=$HOME/.cfg git@github.com:pardom/dotfiles.git $HOME/cfg-tmp

    cp -a $HOME/cfg-tmp/.[!.]* .
    rm -r $HOME/cfg-tmp
fi

if ! [ -x "$(command -v brew)" ]; then
    echo "==> Installing Homebrew..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

if [ -f $HOME/Brewfile ]; then
    echo "==> Installing dependencies..."
    brew bundle
fi

if ! [ -d $HOME/.vim/plugged ]; then
    echo "==> Installing Vim plugins..."
    vim +PlugInstall +qall > /dev/null
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

echo "==> Cleaning up..."

if [ -f $HOME/Brewfile ]; then
    rm $HOME/Brewfile
fi

if [ -f $HOME/README.md ]; then
    rm $HOME/README.md
fi

if [ -f $HOME/bootstrap.sh ]; then
    rm $HOME/bootstrap.sh
fi

echo "==> Finished!"
