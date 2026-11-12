# Case-insensitive completion, falling back to partial-word matches.
zstyle ':completion:*' matcher-list \
  'm:{[:lower:][:upper:]-_}={[:upper:][:lower:]_-}' \
  'r:|=*' \
  'l:|=* r:|=*'
