#!/bin/zsh -f
set -eu

module_dir=${0:A:h}
source "$module_dir/env.zsh"

if [[ ! -r $ANTIDOTE_SCRIPT ]]; then
  printf 'error: antidote is not installed at %s; run switch first\n' \
    "$ANTIDOTE_SCRIPT" >&2
  exit 1
fi
# antidote.zsh reads BASH_VERSION to reject bash, which fails under nounset.
set +u
source "$ANTIDOTE_SCRIPT"
set -u

# Regenerate explicitly during install and update, never during shell startup.
mkdir -p "${ANTIDOTE_PLUGINS:h}"
bundle_file=$(mktemp "$ANTIDOTE_PLUGINS.XXXXXX")
trap 'rm -f -- "$bundle_file"' EXIT
antidote bundle < "$module_dir/plugins.txt" > "$bundle_file"
mv -- "$bundle_file" "$ANTIDOTE_PLUGINS"
