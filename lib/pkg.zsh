# Package helpers for module install.zsh and uninstall.zsh scripts. Each
# function is idempotent: installing an installed package, or uninstalling a
# missing one, does nothing.
#
#   source "${0:A:h:h:h}/lib/pkg.zsh"
#   brew_install fzf
#   cask_install ghostty
#
# switch runs these scripts under `zsh -f`, so this file puts Homebrew on
# PATH itself. It also loads the XDG defaults, so a script run by hand finds
# the same directories as one run by switch.

source ${${(%):-%x}:A:h}/base/xdg.zsh

typeset -gr BREW_BIN=/opt/homebrew/bin/brew

# Directory for generated completion functions. ~/.zshrc adds it to fpath.
typeset -gr COMPLETION_DIR=$XDG_DATA_HOME/zsh/site-functions

if [[ ! -x $BREW_BIN ]]; then
  printf 'error: %s\n' 'Homebrew is not installed; run bootstrap first' >&2
  return 1
fi

eval "$("$BREW_BIN" shellenv zsh)"

# --- Homebrew ----------------------------------------------------------------

# Installed state is read from Homebrew's directories, because `brew list`
# starts a brew process (about 0.2s) for each package.
#
#   formula  $HOMEBREW_PREFIX/opt/<formula>
#   cask     $HOMEBREW_PREFIX/Caskroom/<cask>
#
# Only the packages that need a change reach brew, in a single call.

# Set `reply` to the packages whose directory under $HOMEBREW_PREFIX/$1
# exists (when $2 is 1) or is missing (when $2 is 0).
# Usage: _filter_packages <opt|Caskroom> <0|1> <package>...
function _filter_packages() {
  local package_dir=$HOMEBREW_PREFIX/$1
  local -i want=$2
  local package
  local -i present

  shift 2
  reply=()

  for package in "$@"; do
    # :t keeps the last path part, so tap/name/formula checks <formula>.
    if [[ -e $package_dir/${package:t} ]]; then
      present=1
    else
      present=0
    fi

    if (( present == want )); then
      reply+=("$package")
    fi
  done
}

# Install the formulae that aren't installed. A tap/name/formula argument
# taps the repository first.
# Usage: brew_install <formula>...
function brew_install() {
  _filter_packages opt 0 "$@"

  if (( ${#reply} > 0 )); then
    brew install --formula "${reply[@]}"
  fi
}

# Uninstall the formulae that are installed.
# Usage: brew_uninstall <formula>...
function brew_uninstall() {
  _filter_packages opt 1 "$@"

  if (( ${#reply} > 0 )); then
    brew uninstall --formula "${reply[@]}"
  fi
}

# Install the casks that aren't installed.
# Usage: cask_install <cask>...
function cask_install() {
  _filter_packages Caskroom 0 "$@"

  if (( ${#reply} > 0 )); then
    brew install --cask "${reply[@]}"
  fi
}

# Uninstall the casks that are installed.
# Usage: cask_uninstall <cask>...
function cask_uninstall() {
  _filter_packages Caskroom 1 "$@"

  if (( ${#reply} > 0 )); then
    brew uninstall --cask "${reply[@]}"
  fi
}

# --- Completions -------------------------------------------------------------

# Write the output of a command to completion function $1. For example,
# `completion_install _fzf fzf --zsh` writes fzf's completion to _fzf.
# Usage: completion_install <name> <command>...
function completion_install() {
  local name=$1

  shift

  mkdir -p "$COMPLETION_DIR"
  "$@" > "$COMPLETION_DIR/$name"
}

# Remove completion function $1.
# Usage: completion_uninstall <name>
function completion_uninstall() {
  local name=$1

  rm -f -- "$COMPLETION_DIR/$name"
}
