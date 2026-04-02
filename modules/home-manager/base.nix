{
  pkgs,
  ...
}:
{
  programs.alacritty = {
    enable = true;
    settings = {
      terminal = {
        shell = "${pkgs.zsh}/bin/zsh";
      };
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true; # see note on other shells below
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Nico Vergara";
        email = "me@nicoevergara.com";
      };
      extraConfig = {
        push.autoSetupRemote = true;
        core = {
          editor = "vim";
        };
      };
    };
    ignores = [
      "*.DS_Store"
      ".direnv"
    ];
  };

  programs.vim = {
    enable = true;
    settings = {
      tabstop = 2;
    };
  };

  programs.starship.enable = true;
}
