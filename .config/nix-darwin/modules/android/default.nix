{
  home = {
    sessionVariables = {
      ANDROID_HOME = "$HOME/Library/Android/sdk";
      ANDROID_SDK_HOME = "$ANDROID_HOME";
      ANDROID_SDK_ROOT = "$ANDROID_HOME";
      ANDROID_NDK_HOME = "$ANDROID_HOME/ndk/25.1.8937393";
      PATH = "$PATH:$ANDROID_HOME/platform-tools";
    };

    shellAliases = {
      emulator = "$ANDROID_HOME/emulator/emulator";
    };
  };
}
