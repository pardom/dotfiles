command -v codex >/dev/null 2>&1 || return 0

# compinit runs in .zshrc before interactive modules are loaded.
source <(codex completion zsh)
