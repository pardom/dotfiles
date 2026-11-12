# The scaffold layer. It holds the code shared by the create, delete, add
# and remove commands.
#
#   scaffold/common.zsh  checks, creating directories, the apply hint
#   scaffold/links.zsh   adding and removing roles and modules
#   scaffold/delete.zsh  deleting a module, role or host with its links

source $STOWAWAY_ROOT/lib/repo.zsh
source $STOWAWAY_ROOT/lib/scaffold/common.zsh
source $STOWAWAY_ROOT/lib/scaffold/links.zsh
source $STOWAWAY_ROOT/lib/scaffold/delete.zsh
