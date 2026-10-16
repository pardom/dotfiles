#!/usr/bin/env zsh
set -eu

brew upgrade ollama

# Provision the default model without starting a stopped server.
printf '%s\n' 'Checking for the default Ollama model...'
model=qwen3-coder
if ! models=$(ollama list 2>/dev/null); then
    printf '%s\n' 'SKIPPED: Ollama model updates — server unavailable; leaving it stopped.'
elif printf '%s\n' "$models" | awk 'NR > 1 { print $1 }' | grep -qx "${model}:latest"; then
    printf '%s\n' "$model model already installed locally"
else
    printf '%s\n' "Pulling latest $model model..."
    ollama pull "$model"
fi
