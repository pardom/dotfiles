#!/usr/bin/env zsh
set -eu

if command -v pi >/dev/null 2>&1; then
    exit 0
fi

if ! command -v npm >/dev/null 2>&1; then
    if ! command -v brew >/dev/null 2>&1; then
        printf '%s\n' 'Install Node.js/npm or make Homebrew available before installing Pi.' >&2
        exit 1
    fi
    brew install node
fi

npm install -g --ignore-scripts @earendil-works/pi-coding-agent
