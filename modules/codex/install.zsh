#!/bin/zsh -f
set -eu

source "${0:A:h:h:h}/lib/pkg.zsh"

cask_install codex
completion_install _codex codex completion zsh
