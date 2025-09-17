#!/usr/bin/env zsh

# Ensure tree-sitter is installed
if ! command -v tree-sitter >/dev/null; then
  brew install tree-sitter-cli
fi
