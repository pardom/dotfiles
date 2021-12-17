{ outputs, pkgs, ... }:

{ 
  home = {
    packages = [
      pkgs.fd
      pkgs.lazygit
    ];

    sessionVariables = {
      NVIM_APPNAME = "lazyvim";
      EDITOR = "nvim";
    };
  };

  programs = 
    let
      toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";
    in
  {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      plugins = with pkgs.vimPlugins; [
        {
          plugin = dracula-nvim;
          config = "colorscheme dracula";
        }

        {
          plugin = dressing-nvim;
          config = toLuaFile ./plugins/dressing-nvim.lua;
        }

        {
          plugin = lualine-nvim;
        }

        {
          plugin = neo-tree-nvim;
          config = toLuaFile ./plugins/neo-tree-nvim.lua;
        }

        {
          plugin = noice-nvim;
          config = toLuaFile ./plugins/noice-nvim.lua;
        }
      ];
    };
  };
}

