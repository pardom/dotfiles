# Keep toolchains and installed tools outside the home directory root.
export RUSTUP_HOME="${RUSTUP_HOME:-$XDG_DATA_HOME/rustup}"
export CARGO_HOME="${CARGO_HOME:-$XDG_DATA_HOME/cargo}"
