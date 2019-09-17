# Bash completions
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  source $(brew --prefix)/etc/bash_completion
fi

# load all files from .shell/rc.d directory
if [ -d $HOME/.rc.d ]; then
  for file in $HOME/.rc.d/*.sh; do
    source $file
  done
fi

# load all files from .shell/bashrc.d directory
if [ -d $HOME/.bashrc.d ]; then
  for file in $HOME/.bashrc.d/*.bash; do
    source $file
  done
fi
