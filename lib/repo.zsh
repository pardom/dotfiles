# The repo layer. It reads the repository and this machine's state.
#
#   repo/modules.zsh    resolving a host's links into roles and modules
#                       (also loaded by the shell startup files, on its own)
#   repo/host.zsh       choosing the host and reading the applied-host link
#   repo/state.zsh      the record of modules switch installed

source $STOWAWAY_ROOT/lib/base.zsh
source $STOWAWAY_ROOT/lib/repo/modules.zsh
source $STOWAWAY_ROOT/lib/repo/host.zsh
source $STOWAWAY_ROOT/lib/repo/state.zsh
