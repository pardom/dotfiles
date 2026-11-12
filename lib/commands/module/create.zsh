#!/bin/zsh -f
# Create a module: the .stow-local-ignore link, starter install.zsh and
# uninstall.zsh, and comment-only env.zsh, profile.zsh and rc.zsh. Sourcing a
# comment-only file does nothing, so unused ones are harmless; delete them
# when you like. The module does nothing until `stowaway role add` or
# `stowaway host add` adds it.

set -eu

source $STOWAWAY_ROOT/lib/scaffold.zsh

readonly USAGE='Usage: stowaway module create <NAME>'

function print_help() {
  cat <<EOF
Create a module

$USAGE

Arguments:
  <NAME>  Module directory to create in modules/

Options:
  -h, --help  Print help
EOF
}

# --- Scaffold ----------------------------------------------------------------

# Print each argument as a comment line.
function _print_comment() {
  local line

  for line in "$@"; do
    # A bare "#" for blank lines, so none ends in a space.
    print -r -- "#${line:+ $line}"
  done
}

# Write a starter install.zsh or uninstall.zsh. $1 is the module directory,
# $2 the file name; the rest are its comment lines.
function _write_script() {
  local module_dir=$1
  local file_name=$2

  shift 2

  {
    print '#!/bin/zsh'
    print 'set -eu'
    print
    _print_comment "$@"
  } > "$module_dir/$file_name"
}

# Write a comment-only shell file. $1 is the module directory, $2 the file
# name; the rest are its comment lines.
function _write_shell_file() {
  local module_dir=$1
  local file_name=$2

  shift 2

  _print_comment "$@" > "$module_dir/$file_name"
}

# --- Main --------------------------------------------------------------------

function main() {
  local name=
  local module_dir

  while (( $# > 0 )); do
    case $1 in
      -h|--help)
        print_help
        exit 0
        ;;
      -*)
        die_unexpected_argument "$USAGE" "$1"
        ;;
      *)
        [[ -z $name ]] || die_unexpected_argument "$USAGE" "$1"
        name=$1
        shift
        ;;
    esac
  done

  [[ -n $name ]] || die_missing_argument "$USAGE" '<NAME>'
  require_valid_name "$USAGE" "$name" '<NAME>'
  create_item_directory module "$name"

  module_dir=$STOWAWAY_ROOT/modules/$name

  ln -s ../../.stow-ignore "$module_dir/.stow-local-ignore" \
    || die "could not link modules/$name/.stow-local-ignore"
  _write_script "$module_dir" install.zsh \
    'Install what this module needs. switch runs this on every switch, so' \
    'skip anything already in place.'
  _write_script "$module_dir" uninstall.zsh \
    'Remove what install.zsh installed. switch runs this once the host no' \
    'longer has this module; do nothing if it is already gone.'
  _write_shell_file "$module_dir" env.zsh \
    'Sourced by every zsh, including scripts. Keep it to variables other' \
    'programs need, such as EDITOR. Put PATH additions in profile.zsh:' \
    "export ${${name//[^A-Za-z0-9]/_}:u}_HOME=\"\$XDG_DATA_HOME/$name\""
  _write_shell_file "$module_dir" profile.zsh \
    'Sourced by login shells. Use it for one-time setup per login session' \
    'and for PATH additions. macOS reorders PATH after env.zsh runs, so a' \
    'directory added there ends up behind /usr/bin.' \
    '' \
    "path=(\"\$XDG_DATA_HOME/$name/bin\" \$path)"
  _write_shell_file "$module_dir" rc.zsh \
    'Sourced by interactive shells: aliases, functions, prompt, key' \
    'bindings. Skip quietly until install.zsh has installed the tool:' \
    '' \
    "if ! command -v $name >/dev/null 2>&1; then" \
    '  return 0' \
    'fi'

  print -r -- "Created modules/$name"
  print
  print 'Fill in its files, then add it to a role or host:'
  print
  print -r -- "  stowaway role add <ROLE> --module $name"
}

main "$@"
