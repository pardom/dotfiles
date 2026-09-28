command -v tinty >/dev/null 2>&1 || return 0

# Theme scripts must run in this shell to set BASE16_THEME and color variables.
tinty_load_shell_theme() {
    local data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/tinted-theming/tinty"
    local script
    # (N) skips an empty cache before the first theme has been applied.
    for script in "$data_dir"/*.sh(N); do
        [[ -f "$script" ]] || continue
        source "$script" || return
    done
}

tinty_source_shell_theme() {
    command tinty "$@" || return
    case "${1:-}" in
        apply|init) tinty_load_shell_theme ;;
    esac
}

tinty_picker() {
    if ! command -v fzf >/dev/null 2>&1; then
        printf '%s\n' 'tinty_picker requires fzf.' >&2
        return 1
    fi

    local selected
    local -a colors
    if [[ -n ${BASE16_COLOR_02_HEX:-} && -n ${BASE16_COLOR_05_HEX:-} ]]; then
        colors=(--color "border:#$BASE16_COLOR_02_HEX,label:#$BASE16_COLOR_05_HEX")
    fi
    selected=$(command tinty list | grep base16 | fzf \
        --style default \
        "${colors[@]}" \
        --preview-window=right,66% \
        --preview 'tinty info {}') || return
    [[ -n "$selected" ]] || return 0
    # Apply in the parent shell so environment changes persist.
    tinty_source_shell_theme apply "$selected"
}

# Restore cached shell colors without syncing repositories on shell startup.
tinty_load_shell_theme
alias tinty=tinty_source_shell_theme
