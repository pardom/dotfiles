{ config, pkgs, ... }:

{
  programs = {
    tmux = {
      enable = true;
      plugins = [
        pkgs.tmuxPlugins.battery
        pkgs.tmuxPlugins.continuum
        pkgs.tmuxPlugins.pain-control
        pkgs.tmuxPlugins.resurrect
        pkgs.tmuxPlugins.sensible
        pkgs.tmuxPlugins.vim-tmux-navigator
        pkgs.tmuxPlugins.yank
      ];
      shortcut = "space";
    };
  };
}
