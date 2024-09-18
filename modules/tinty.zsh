#!/usr/bin/env zsh

export BASE16_SHELL_ENABLE_VARS=1;

tinty_source_shell_theme() {
	tinty_config="$HOME/tinted-theming/tinty/config.toml"
	tinty_data_dir="$HOME/.local/share/tinted-theming/tinty"

	tinty --config $tinty_config --data-dir $tinty_data_dir $@
	subcommand="$1"

	if [ "$subcommand" = "apply" ] || [ "$subcommand" = "init" ]; then
		for tinty_script_file in $(find "$tinty_data_dir" -maxdepth 1 -type f -name "*.sh"); do
			. $tinty_script_file
		done

		unset tinty_config
		unset tinty_data_dir
	fi

	unset subcommand
}

if [ -n "$(command -v 'tinty')" ]; then
	tinty_source_shell_theme "init"
	alias tinty=tinty_source_shell_theme
fi
