# Keep downloaded modules and installed tools outside the config directory.
export GOPATH="${GOPATH:-${XDG_DATA_HOME:-$HOME/.local/share}/go}"
# If GOPATH contains multiple entries, Go installs tools under the first one.
export GOBIN="${GOBIN:-${GOPATH%%:*}/bin}"

# Avoid adding another copy when a nested shell reads this file.
case ":$PATH:" in
    *":$GOBIN:"*) ;;
    *) export PATH="$GOBIN:$PATH" ;;
esac
