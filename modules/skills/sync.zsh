#!/usr/bin/env zsh
set -eu

# The skills CLI owns ~/.agents/skills. Fetch personal skills from the private
# repository using existing Git SSH authentication, not from this checkout.
# Re-adding also discovers new skills; update.zsh refreshes installed skills.
skills_source='git@github.com:pardom/skills.git'

if ! command -v npx >/dev/null 2>&1; then
    printf '%s\n' 'Install Node.js and make npx available on PATH before installing skills.' >&2
    exit 1
fi

npx --yes skills add "$skills_source" --global --skill '*' \
    --agent claude-code --agent codex --yes

# Do not prune installed skills based on the old local source. Retiring a skill
# is an explicit `skills remove` operation, not a side effect of syncing.
