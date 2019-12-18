if [[ $XPC_SERVICE_NAME != *"idea"* && $XPC_SERVICE_NAME != *"jetbrains"* && $XPC_SERVICE_NAME != *"android.studio"* && $XPC_SERVICE_NAME != *".studio"* ]]; then
  BASE16_SHELL=$HOME/.base16-manager/chriskempson/base16-shell/
  [ -n "$PS1" ] && [ -s $BASE16_SHELL/profile_helper.sh ] && eval "$($BASE16_SHELL/profile_helper.sh)"
fi
