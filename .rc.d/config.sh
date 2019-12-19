#!/usr/bin/env bash

#   Configuration {{
 
if [ -d $HOME/.cfg ]; then
    alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
    config config status.showUntrackedFiles no
fi

# }}}
