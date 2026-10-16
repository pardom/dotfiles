# Shared by module installers; source using an absolute, script-relative path.
require_brew() {
    if ! command -v brew >/dev/null 2>&1; then
        printf 'Install Homebrew and make brew available on PATH before installing %s.\n' "$1" >&2
        return 1
    fi
}

# brew_install [--formula|--cask] package [command-or-absolute-app-directory]
# By default, detect the command (package name when omitted) on PATH.
# --formula requires the Homebrew formula even if a system command exists.
# --cask installs a cask, detecting either its command or supplied app directory.
brew_install() {
    local mode=command
    case "$1" in
        --formula|--cask) mode=${1#--}; shift ;;
    esac
    local package=$1 target=${2:-${1:t}}
    local -a install_options=()

    if [[ "$mode" == formula ]]; then
        require_brew "$package" || return $?
        if brew list --formula --versions "$package" >/dev/null 2>&1; then
            return 0
        fi
    else
        if [[ "$target" == /* ]]; then
            [[ ! -d "$target" ]] || return 0
        elif command -v "$target" >/dev/null 2>&1; then
            return 0
        fi
        require_brew "$package" || return $?
        if [[ "$mode" == cask ]]; then
            install_options=(--cask)
        fi
    fi

    brew install "${install_options[@]}" "$package"
}
