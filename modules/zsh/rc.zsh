# Case-insensitive completion, with the original partial-match fallbacks.
zstyle ':completion:*' matcher-list \
    'm:{[:lower:][:upper:]-_}={[:upper:][:lower:]_-}' \
    'r:|=*' \
    'l:|=* r:|=*'
