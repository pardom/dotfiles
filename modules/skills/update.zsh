#!/usr/bin/env zsh
set -eu

# Updates personal and third-party skills from their recorded remote sources.
# Run sync.zsh to discover newly added skills in the personal repository.
npx --yes skills update --global --yes
