{
  config,
  pkgs,
  lib,
  username,
  ...
}: let
  macosPackages = with pkgs; [
    rectangle-pro
  ];
  generalDesktopPackages = with pkgs; [
    # spotify
    dbeaver-bin
    alacritty
  ];
in {
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "rectangle-pro"
    ];

  home.packages =
    (with pkgs; [
      alejandra
      git
      kubectl
    ])
    ++ generalDesktopPackages
    ++ macosPackages
    ++ [
      (
        with pkgs.google-cloud-sdk;
          withExtraComponents [
            components.gke-gcloud-auth-plugin
            components.cloud-sql-proxy
          ]
      )
    ];

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
  };

  programs.vim = {
    enable = true;
    settings = {
      tabstop = 2;
    };
  };

  programs.starship.enable = true;

  programs.home-manager.enable = true;

  home.stateVersion = "25.05"; # Do not modify without reading changelogs
}
