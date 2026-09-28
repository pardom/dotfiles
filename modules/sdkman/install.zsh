#!/usr/bin/env zsh
set -eu

source "$(dirname "$0")/env.zsh"

if [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
    exit 0
fi

if [[ -e "$SDKMAN_DIR" || -L "$SDKMAN_DIR" ]]; then
    printf 'SDKMAN directory exists but is incomplete: %s\n' "$SDKMAN_DIR" >&2
    exit 1
fi

for dependency in curl zip unzip; do
    if ! command -v "$dependency" >/dev/null 2>&1; then
        printf 'Install %s before installing SDKMAN.\n' "$dependency" >&2
        exit 1
    fi
done

installer=$(mktemp "${TMPDIR:-/tmp}/sdkman-install.XXXXXX")
trap 'rm -f -- "$installer"' EXIT
# Our module owns initialization; leave the managed startup files alone.
curl -fsSL 'https://get.sdkman.io?rcupdate=false' -o "$installer"
zsh "$installer"

if [[ ! -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
    printf '%s\n' 'SDKMAN installation did not create its initialization script.' >&2
    exit 1
fi
