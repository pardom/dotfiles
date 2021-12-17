{ inputs, config, pkgs, ... }:

{
  imports = [
    ./modules/android
    ./modules/base16-shell
    ./modules/bat
    ./modules/eza
    ./modules/fzf
    ./modules/git
    ./modules/neovim
    ./modules/tmux
    ./modules/zsh
  ];

  home = {
    stateVersion = "23.11";

    packages = [
      pkgs.exercism
      pkgs.jq
      # pkgs.mono
      pkgs.ripgrep
      pkgs.tldr
      pkgs.tree
      pkgs.watchman
    ];
  };

  programs.home-manager.enable = true;
}
