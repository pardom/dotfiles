#!/usr/bin/env zsh

DIRECTORY="$HOME/.sdkman"

if [ -d "$DIRECTORY" ]; then
  source "$DIRECTORY/bin/sdkman-init.sh"
else
  vared -p "SDKMAN is not installed. Would you like to install it? (Y/N): " -c confirm
  if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
    curl -s "https://get.sdkman.io" | bash
    source "$DIRECTORY/bin/sdkman-init.sh"
  fi
fi


