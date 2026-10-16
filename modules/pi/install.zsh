#!/usr/bin/env zsh
set -eu

source "${0:A:h:h:h}/scripts/lib/brew.zsh"

# Provider/model configuration is managed through Pi's UI, not Stow.
model=qwen3-coder
settings="$HOME/.pi/agent/settings.json"

# The formula tracks pi.dev releases; this module's update.zsh upgrades it.
brew_install pi-coding-agent pi

if ! command -v jq >/dev/null 2>&1; then
    printf '%s\n' 'Install jq and make it available on PATH before configuring pi.' >&2
    exit 1
fi

# Set up the packages in settings.json
mkdir -p "${settings:h}"
[[ -s "$settings" ]] || printf '{}\n' > "$settings"
jq --arg model "$model" \
    'if has("defaultProvider") then . else . + {defaultProvider: "ollama", defaultModel: $model, packages: ["npm:pi-web-access", "npm:pi-subagents", "npm:pi-mcp-adapter"]} end' \
    "$settings" > "$settings.tmp"
mv "$settings.tmp" "$settings"

# Verify that pi is working and update extensions if needed
if command -v pi >/dev/null 2>&1; then
    pi update
else
    printf '%s\n' 'pi installation complete, please run "pi update" to install extensions' >&2
fi
