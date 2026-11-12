# Resolves a host's modules by walking its symbolic links.
#
#   hosts/<host>/<name>  -> ../../roles/<role>      a role: walked in turn
#   hosts/<host>/<name>  -> ../../modules/<module>  a module: recorded
#   roles/<role>/<name>  -> either of the above
#
# Hosts and roles are plain directories of links, so a role can include other
# roles and a host can link modules directly. A module reached by several
# paths is recorded once. Load order is alphabetical by module name; modules
# must not depend on each other's load order.
#
# The walk only records names. It never loads a module, because a file
# sourced inside a function runs in that function's scope, and a plain
# `typeset` in a plugin would create a variable local to that function. Callers loop
# over the result and source module files at the top level.
#
# Used by the zsh startup files (~/.zshenv, ~/.zprofile and ~/.zshrc) and the commands.
# The startup files source this file on its own, so it must not depend on
# the rest of lib/. They walk the links on every shell start, so a link or
# module edit takes effect in the next shell without running switch.

# --- Results -----------------------------------------------------------------

# The repository root, three levels above this file (lib/repo/modules.zsh).
# The stowaway script has already set it, read-only, when the commands load
# this file, so assign it only when it is unset.
: ${STOWAWAY_ROOT:=${${(%):-%x}:A:h:h:h}}

# Filled by resolve_host.
typeset -ga STOWAWAY_ROLES
typeset -ga STOWAWAY_MODULES

# --- Walk --------------------------------------------------------------------

# Add every role and module linked from directory $1, recursively, to
# STOWAWAY_ROLES and STOWAWAY_MODULES.
function _walk_links() {
  emulate -L zsh

  local link_dir=$1
  local entry
  local target

  for entry in "$link_dir"/*(N@); do
    # Only directory targets can be roles or modules. This also skips
    # broken links.
    if [[ ! -d $entry ]]; then
      continue
    fi

    target=${entry:A}

    case ${target:h} in
      "$STOWAWAY_ROOT/modules")
        if (( ! ${STOWAWAY_MODULES[(Ie)${target:t}]} )); then
          STOWAWAY_MODULES+=(${target:t})
        fi
        ;;
      "$STOWAWAY_ROOT/roles")
        # Visiting each role once also stops cycles.
        if (( ! ${STOWAWAY_ROLES[(Ie)${target:t}]} )); then
          STOWAWAY_ROLES+=(${target:t})
          _walk_links "$target"
        fi
        ;;
    esac
  done
}

# --- Entry points ------------------------------------------------------------

# Set STOWAWAY_ROLES and STOWAWAY_MODULES to the roles and modules that host
# directory $1 (or a link to one) includes, each sorted by name.
function resolve_host() {
  emulate -L zsh

  local host_dir=$1

  STOWAWAY_ROLES=()
  STOWAWAY_MODULES=()

  _walk_links "$host_dir"

  STOWAWAY_ROLES=("${(@o)STOWAWAY_ROLES}")
  STOWAWAY_MODULES=("${(@o)STOWAWAY_MODULES}")
}

# Set `reply` to the files for one startup phase (env, profile or rc) of the
# resolved modules, in order. Modules without that file are skipped. `reply`
# is zsh's conventional name for an array a function returns.
function list_phase_files() {
  emulate -L zsh

  local phase=$1
  local module_name
  local module_file

  reply=()

  for module_name in "${STOWAWAY_MODULES[@]}"; do
    module_file=$STOWAWAY_ROOT/modules/$module_name/$phase.zsh

    if [[ -r $module_file ]]; then
      reply+=("$module_file")
    fi
  done
}
