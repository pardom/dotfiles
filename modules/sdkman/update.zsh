#!/usr/bin/env zsh
set -e

source "$(dirname "$0")/env.zsh"

if [[ ! -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
    printf 'SDKMAN is not installed at %s; run install.zsh first.\n' "$SDKMAN_DIR" >&2
    exit 1
fi

# sdk is a shell function; SDKMAN's scripts are not nounset-safe.
source "$SDKMAN_DIR/bin/sdkman-init.sh"
sdk selfupdate
# Refresh the candidate list; installed SDK versions are managed by hand.
sdk update
