{
  config,
  pkgs,
  lib,
  username,
  ...
}: let
  rootPath = ../../../..;
  generalDesktopPackages = with pkgs; [
    dbeaver-bin
    anki-bin
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

  programs.home-manager.enable = true;

  home.stateVersion = "25.05"; # Do not modify without reading changelogs
}
