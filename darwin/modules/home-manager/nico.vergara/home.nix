{
  config,
  pkgs,
  lib,
  username,
  ...
}: let
  rootPath = ../../../..;
  generalDesktopPackages = with pkgs; [
    # dbeaver-bin
  ];
in {
  home.packages =
    generalDesktopPackages
    ++ import "${rootPath}/modules/home-manager/devenv.nix" {inherit pkgs config;};

  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        size = 16;
      };
    };
  };

  imports = [
    "${rootPath}/modules/home-manager/base.nix"
  ];

  # Configure AGENTS.md configuration file for Cursor
  home.file.".cursor/AGENTS.md".source = ./cursor/AGENTS.md;

  programs.home-manager.enable = true;

  home.stateVersion = "25.05"; # Do not modify without reading changelogs
}
