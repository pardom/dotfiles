# adb is in the SDK's platform-tools. The (U) flag on path keeps only the
# first copy of each entry.
typeset -U path
path=("$ANDROID_HOME/platform-tools" $path)
