{ pkgs, ... }:

let
  base16-shell = pkgs.fetchFromGitHub {
    owner = "chriskempson";
    repo = "base16-shell";
    rev = "588691ba71b47e75793ed9edfcfaa058326a6f41";
    sha256 = "sha256-X89FsG9QICDw3jZvOCB/KsPBVOLUeE7xN3VCtf0DD3E=";
  };

  base16-command = ''
    # Base16 Shell
    BASE16_SHELL=${base16-shell.outPath}
    [ -n "$PS1" ] && \
      [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        source "$BASE16_SHELL/profile_helper.sh"

    base16_dracula
  '';
in
{
  programs.bash.initExtra = base16-command;
  programs.zsh.initExtra = base16-command;
}
