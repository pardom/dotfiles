# Decides what switch will do, without changing anything. plan_switch turns
# the resolved modules and the record of the last switch into a list of
# actions; lib/switch/apply.zsh previews or runs them.
#
#   link-startup               link the shell startup files into $HOME
#   link-modules <stow args>   unlink dropped modules (-D ...) and relink the
#                              host's (-R ...)
#   link-host <host>           point ~/.config/stowaway/host at hosts/<host>
#   uninstall <module>         run modules/<module>/uninstall.zsh
#   untrack <module>           forget a deleted module; its packages and
#                              links stay
#   install <module>           run modules/<module>/install.zsh
#
# Each action is one string of words. Module and host names can't contain
# spaces (lib/base/name.zsh), so splitting on spaces is safe.
#
# Run resolve_host first; the plan reads STOWAWAY_MODULES.

# Exit unless the repository root and every resolved module have their Stow
# ignore rules. The root's file limits it to the shell startup files, and the
# modules' links to the shared rules limit them to dot-* files. Without one,
# Stow falls back to its defaults and links everything else into $HOME.
function require_ignore_policies() {
  local module_name

  if [[ ! -f $STOWAWAY_ROOT/.stow-local-ignore ]]; then
    die "missing Stow ignore policy: .stow-local-ignore"
  fi

  for module_name in $STOWAWAY_MODULES; do
    if [[ ! -f $STOWAWAY_ROOT/modules/$module_name/.stow-local-ignore ]]; then
      die "missing Stow ignore policy: modules/$module_name/.stow-local-ignore"
    fi
  done
}

# Set `reply` to the actions that apply host $1, in order.
function plan_switch() {
  local host_name=$1
  local module_name
  local -a all_modules
  local -a unused_modules
  local -a dropped_modules
  local -a stow_args
  local -a actions

  all_modules=("$STOWAWAY_ROOT"/modules/*(N/:t))
  unused_modules=(${all_modules:|STOWAWAY_MODULES})
  read_installed
  dropped_modules=(${reply:|STOWAWAY_MODULES})

  actions=(link-startup)

  # Unlink and relink in one Stow run, so its conflict check sees the links
  # being removed.
  if (( ${#unused_modules} > 0 )); then
    stow_args+=(-D $unused_modules)
  fi
  if (( ${#STOWAWAY_MODULES} > 0 )); then
    stow_args+=(-R $STOWAWAY_MODULES)
  fi
  if (( ${#stow_args} > 0 )); then
    actions+=("link-modules $stow_args")
  fi

  actions+=("link-host $host_name")

  # Uninstalls run first. When one module replaces another that manages the
  # same tool, the old module's uninstall.zsh can't then remove what the new
  # one's install.zsh put in place.
  for module_name in $dropped_modules; do
    if [[ ! -d $STOWAWAY_ROOT/modules/$module_name ]]; then
      actions+=("untrack $module_name")
    elif [[ -f $STOWAWAY_ROOT/modules/$module_name/uninstall.zsh ]]; then
      actions+=("uninstall $module_name")
    fi
  done

  for module_name in $STOWAWAY_MODULES; do
    if [[ -f $STOWAWAY_ROOT/modules/$module_name/install.zsh ]]; then
      actions+=("install $module_name")
    fi
  done

  reply=("${actions[@]}")
}
