#!/usr/bin/env zsh
set -eu

# Karabiner only reloads config changes when ~/.config/karabiner, not
# karabiner.json, is the symlink. Stow runs with --no-folding and skips this
# directory (.stow-local-ignore), so link the directory here.
config_source="${0:A:h:h:h}/.config/karabiner"
config_link="$HOME/.config/karabiner"
if [[ -L "$config_link" ]]; then
    [[ "${config_link:A}" == "${config_source:A}" ]] ||
        printf 'warning: %s points to %s, not %s\n' "$config_link" "$(readlink "$config_link")" "$config_source" >&2
elif [[ -e "$config_link" ]]; then
    printf 'warning: %s is a real directory; move it aside to link %s\n' "$config_link" "$config_source" >&2
else
    mkdir -p "${config_link:h}"
    ln -s "$config_source" "$config_link"
fi

# Karabiner is a macOS app, so detect the app rather than a PATH entry.
if [[ -d /Applications/Karabiner-Elements.app ]]; then
    exit 0
fi

if ! command -v brew >/dev/null 2>&1; then
    printf '%s\n' 'Install Homebrew and make brew available on PATH before installing Karabiner-Elements.' >&2
    exit 1
fi

brew install --cask karabiner-elements
