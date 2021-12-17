#!/bin/sh

if [ ! -d $HOME/.sdkman ]; then
    echo "Installing SDKMAN"
    curl -s "https://get.sdkman.io" | bash
fi


[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

export SDKMAN_DIR="$HOME/.sdkman"
export JAVA_HOME="$SDKMAN_DIR/candidates/java/current"

