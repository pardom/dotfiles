# Keep npm and the REPL out of the home directory root. The global prefix
# stays Homebrew's, so `npm install -g` binaries land on PATH already.
export NPM_CONFIG_USERCONFIG="${NPM_CONFIG_USERCONFIG:-$XDG_CONFIG_HOME/npm/npmrc}"
export NPM_CONFIG_CACHE="${NPM_CONFIG_CACHE:-$XDG_CACHE_HOME/npm}"
export NODE_REPL_HISTORY="${NODE_REPL_HISTORY:-$XDG_STATE_HOME/node/repl_history}"
