{
  config,
  pkgs,
  ...
}: {
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
    userName = "Nico Vergara";
    userEmail = "me@nicoevergara.com";
    ignores = [
      "*.DS_Store"
      ".direnv"
      ".envrc"
      "default.nix"
    ];
    extraConfig = {
      push.autoSetupRemote = true;
      core = {
        editor = "vim";
      };
    };
  };

  programs.vim = {
    enable = true;
    settings = {
      tabstop = 2;
    };
  };

  programs.starship.enable = true;
}
