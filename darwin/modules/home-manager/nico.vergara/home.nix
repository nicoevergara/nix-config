{
  config,
  pkgs,
  lib,
  username,
  ...
}: let
  rootPath = ../../../..;
  generalDesktopPackages = with pkgs; [];
in {
  # Enable home-manager
  programs.home-manager.enable = true;

  # Link apps to the home directory
  targets.darwin.linkApps.enable = true;
  targets.darwin.copyApps.enable = false;

  # Set packages to install with home-manager
  home.packages =
    generalDesktopPackages
    ++ import "${rootPath}/modules/home-manager/devenv.nix" {inherit pkgs config;};

  imports = [
    "${rootPath}/modules/home-manager/base.nix"
  ];

  # Configure AGENTS.md configuration file for Cursor
  home.file.".cursor/AGENTS.md".source = ./configs/AGENTS.md;

  home.stateVersion = "25.11"; # Do not modify without reading changelogs
}
