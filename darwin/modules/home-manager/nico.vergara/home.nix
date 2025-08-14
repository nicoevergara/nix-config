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
    alacritty
    anki-bin
  ];
in {
  home.packages =
    generalDesktopPackages
    ++ import "${rootPath}/modules/home-manager/devenv.nix" {inherit pkgs config;};

  imports = [
    "${rootPath}/modules/home-manager/base.nix"
  ];

  programs.home-manager.enable = true;

  home.stateVersion = "25.05"; # Do not modify without reading changelogs
}
