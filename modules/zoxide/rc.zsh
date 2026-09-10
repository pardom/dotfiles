# Preserve the original guard against Claude Code snapshotting this alias.
[[ -n ${CLAUDECODE:-} ]] && return 0
command -v zoxide >/dev/null 2>&1 || return 0

eval "$(zoxide init zsh)"
alias cd='z'
