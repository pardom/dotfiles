# Cargo-installed tools first, then the rustup proxies. Homebrew's rustup is
# keg-only; its bin holds rustup and the cargo/rustc proxies. brew shellenv
# may not have run yet when this loads. The (U) flag on path keeps only the
# first copy of each entry, so a parent shell's additions aren't repeated.
typeset -U path
path=(
  "$CARGO_HOME/bin"
  "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/rustup/bin"
  $path
)
