#!/usr/bin/env zsh
set -eu

# Homebrew owns the executable; the commands below manage extensions.
brew upgrade pi-coding-agent

# Update pi agent and ensure extensions are properly installed
printf '%s\n' 'Updating pi agent and managing extensions...'

if command -v pi >/dev/null 2>&1; then
    # First update pi itself
    printf '%s\n' 'Updating pi agent...'
    pi update pi
    
    # Then make sure our specific packages are installed and up-to-date
    printf '%s\n' 'Ensuring required packages are installed...'
    
    # Get current packages in settings  
    settings="$HOME/.pi/agent/settings.json"
    if [[ -f "$settings" ]]; then
        # Check if the packages we need are present
        packages=("npm:pi-web-access" "npm:pi-subagents" "npm:pi-mcp-adapter")
        for pkg in "${packages[@]}"; do
            if ! pi list | grep -q "$pkg"; then
                printf '%s\n' "Installing missing package: $pkg"
                pi install $pkg
            fi
        done
    else 
        printf '%s\n' 'Settings file not found, reinstalling pi...'
        ~/.dotfiles/modules/pi/install.zsh
    fi
    
    printf '%s\n' 'Pi agent and extensions updated successfully'
else
    printf '%s\n' 'Pi is not installed. Run install.zsh first.' >&2
    exit 1
fi

printf '%s\n' 'Update complete!'
