#!/usr/bin/env zsh
set -eu

source "${0:A:h:h:h}/scripts/lib/brew.zsh"

# Homebrew is needed even when ollama exists, to manage its service.
require_brew ollama
# Use the formula so the server runs as a brew service.
brew_install ollama

# Pi's ollama provider expects the server on localhost:11434 at all times.
if [[ $(brew services info ollama --json | jq -r '.[0].running') != true ]]; then
    brew services start ollama
fi

# Provision the default model used by Pi.
model=qwen3-coder

if ! command -v ollama >/dev/null 2>&1; then
    printf '%s\n' "Make ollama available on PATH before provisioning $model." >&2
    exit 1
fi

# brew services starts the server asynchronously.
for _ in {1..30}; do
    ollama list >/dev/null 2>&1 && break
    sleep 1
done

# Skip the registry round trip when the model is already pulled.
if ! ollama list | awk 'NR > 1 { print $1 }' | grep -qx "${model}:latest"; then
    ollama pull "$model"
fi
