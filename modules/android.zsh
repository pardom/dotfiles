#!/usr/bin/env zsh

export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_SDK_HOME="$HOME/Library/Android/sdk"
export ANDROID_NDK="$ANDROID_HOME/ndk/25.1.8937393"
export ANDROID_NDK_HOME="$ANDROID_NDK"
export ANDROID_NDK_ROOT="$ANDROID_NDK"
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_NDK_HOME:$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64/bin/"

