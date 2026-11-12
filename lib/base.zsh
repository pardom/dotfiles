# The base layer. It holds general helpers that have no knowledge of hosts,
# roles or modules.
#
#   base/xdg.zsh       XDG Base Directory defaults
#                      (also loaded by ~/.zshenv, on its own)
#   base/output.zsh    step headings and die
#   base/cli.zsh       usage errors
#   base/name.zsh      the rule for host, role and module names
#   base/symlinks.zsh  reading symbolic links without following them
#
# Layers load the one below them: base <- repo <- scaffold, switch. A
# command sources the one layer it needs.

source $STOWAWAY_ROOT/lib/base/xdg.zsh
source $STOWAWAY_ROOT/lib/base/output.zsh
source $STOWAWAY_ROOT/lib/base/cli.zsh
source $STOWAWAY_ROOT/lib/base/name.zsh
source $STOWAWAY_ROOT/lib/base/symlinks.zsh
