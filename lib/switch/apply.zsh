# Runs the actions from lib/switch/plan.zsh, or previews them in a dry run.
# After a real run, it records which modules are installed.
#
# A Stow failure stops switch, since nothing after it should run against
# half-linked config. A failing install or uninstall script doesn't: the rest
# still run, and the failures are listed at the end.

# --- Stow --------------------------------------------------------------------

# Run a command with its own empty working directory and HOME. Stow has no
# switch to ignore .stowrc files; this keeps any in the working directory or
# HOME from changing the result. The target and package ignore rules are
# given explicitly.
function _run_isolated() (
  local resource_dir

  resource_dir=$(mktemp -d "${TMPDIR:-/tmp}/stowaway.XXXXXXXXXX") \
    || return 1
  trap 'rmdir -- "$resource_dir"' EXIT

  builtin cd -q -- "$resource_dir" || return 1
  HOME=$resource_dir "$@"
)

# Run Stow on the modules: modules/<name>/dot-config -> ~/.config, and so on.
function _stow_modules() {
  _run_isolated stow \
    --dir="$STOWAWAY_ROOT/modules" \
    --target="$HOME" \
    --dotfiles \
    --no-folding \
    "$@"
}

# Run Stow on the shell startup files (.zshenv, .zshrc, ...). The repository
# root is the package "."; its .stow-local-ignore lets only those through.
# The package comes last: Stow applies an action flag such as -R only to the
# packages after it.
function _stow_startup() {
  _run_isolated stow \
    --dir="$STOWAWAY_ROOT" \
    --target="$HOME" \
    --no-folding \
    "$@" .
}

# Run Stow function $1 with the rest of the arguments in simulation mode
# (-n), printing each change it would make (-v). Returns Stow's status, so a
# conflict stops a dry run where it would stop the real one.
function _preview_stow() {
  local stow_function=$1

  shift
  # Stow warns that it's simulating on every run; drop that line.
  $stow_function -n -v "$@" 2>&1 \
    | { grep -v '^WARNING: in simulation mode' || true }
  return ${pipestatus[1]}
}

# --- Actions -----------------------------------------------------------------

# Print the heading an action starts with, if it has one.
function _print_heading() {
  local action=$1
  local module_name=${2-}

  case $action in
    link-startup) print_step 'Links' ;;
    install)      print_step "Checking $module_name" ;;
    uninstall)    print_step "Uninstalling $module_name" ;;
  esac
}

# Print what an action would do.
function _preview_action() {
  local action=$1

  shift
  case $action in
    link-startup)
      _preview_stow _stow_startup -R || exit $?
      ;;
    link-modules)
      _preview_stow _stow_modules "$@" || exit $?
      ;;
    link-host)
      print -r -- "Would link ${HOST_LINK/#$HOME/~} -> hosts/$1"
      ;;
    install|uninstall)
      print -r -- "Would run modules/$1/$action.zsh"
      ;;
    untrack)
      print -r -- "Would untrack $1 (module deleted; packages left installed)"
      print -r -- "  Links into modules/$1 stay in place; remove them by hand."
      ;;
  esac
}

# Run an action. Fails only if an install or uninstall script fails, and
# exits on any other failure.
function _run_action() {
  local action=$1

  shift
  case $action in
    link-startup)
      # -R relinks: removes the package's old links, then links it again.
      _stow_startup -R || exit $?
      ;;
    link-modules)
      _stow_modules "$@" || exit $?
      ;;
    link-host)
      mkdir -p "${HOST_LINK:h}" || exit $?
      # -n: replace the old link itself, not something inside its target.
      ln -sfn "$STOWAWAY_ROOT/hosts/$1" "$HOST_LINK" || exit $?
      print -r -- "Linked ${HOST_LINK/#$HOME/~} -> hosts/$1"
      ;;
    install|uninstall)
      # zsh -f skips the startup files, so each script starts clean. The
      # XDG variables are exported by lib/base/xdg.zsh.
      /bin/zsh -f "$STOWAWAY_ROOT/modules/$1/$action.zsh"
      ;;
    untrack)
      print -r -- "Untracked $1 (module deleted; packages left installed)"
      # Stow can't unlink a package that no longer exists.
      print -r -- "  Links into modules/$1 stay in place; remove them by hand."
      ;;
  esac
}

# --- Entry point -------------------------------------------------------------

# Preview (dry_run 1) or run the actions in order. After a real run, record
# the installed modules: the target modules, plus any whose uninstall failed
# so the next switch retries it. Fails if any script or the record failed.
# Usage: apply_switch <dry_run: 0|1> <action>...
function apply_switch() {
  local dry_run=$1
  local action
  local -a words
  local -a failed_installs
  local -a failed_uninstalls
  local -i record_failed=0

  shift

  for action in "$@"; do
    # "install alpha" -> (install alpha)
    words=(${=action})
    _print_heading $words

    if (( dry_run )); then
      _preview_action $words
    elif ! _run_action $words; then
      case ${words[1]} in
        install)   failed_installs+=(${words[2]}) ;;
        uninstall) failed_uninstalls+=(${words[2]}) ;;
      esac
    fi
  done

  if (( dry_run )); then
    return 0
  fi

  if ! write_installed $STOWAWAY_MODULES $failed_uninstalls; then
    printf '\nFailed to record installed modules: %s\n' "$INSTALLED_FILE" >&2
    record_failed=1
  fi
  if (( ${#failed_installs} > 0 )); then
    printf '\nInstall failed for: %s\n' "${failed_installs[*]}" >&2
  fi
  if (( ${#failed_uninstalls} > 0 )); then
    printf '\nUninstall failed for: %s\n' "${failed_uninstalls[*]}" >&2
  fi

  (( ${#failed_installs} + ${#failed_uninstalls} + record_failed == 0 ))
}
