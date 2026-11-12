# The switch layer. plan.zsh decides which actions apply a host, and
# apply.zsh runs them.
#
#   switch/plan.zsh   deciding the actions without changing anything
#   switch/apply.zsh  previewing or running each action

source $STOWAWAY_ROOT/lib/repo.zsh
source $STOWAWAY_ROOT/lib/switch/plan.zsh
source $STOWAWAY_ROOT/lib/switch/apply.zsh
