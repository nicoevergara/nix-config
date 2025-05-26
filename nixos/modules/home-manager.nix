{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    <home-manager/nixos>
  ];

  home-manager.useGlobalPkgs = true;

  home-manager.users.nicoevergara = {pkgs, ...}: let
    unstable = import <nixos-unstable> {
      config = {
        allowUnfree = true;
      };
    };
  in {
    imports = [<plasma-manager/modules>];
    nixpkgs.config.allowUnfree = true;
    home.packages = with pkgs;
      [
        anki
        emacs
        zoom-us
        libreoffice-qt6-fresh
        chromium
        fuse3
        alejandra
        nmap
        git
        usbutils
        xclip
      ]
      ++ [
        unstable.filen-cli
      ];

    systemd.user.timers.filen-sync = {
      Unit = {
        Description = "A systemd timer for filen syncing";
      };

      Timer = {
        OnStartupSec = "1min";
        OnUnitActiveSec = "30min";
        Unit = "filen-sync.service";
      };

      Install = {
        WantedBy = ["default.target"];
      };
    };

    systemd.user.services.filen-sync = {
      Unit = {
        Description = "Sync with Filen using filen-cli sync";
        After = ["network.target"];
      };

      Service = {
        Type = "oneshot";
        ExecStart = ''
          ${unstable.filen-cli}/bin/filen sync ${config.users.users.nicoevergara.home}/Documents:/
        '';
      };
    };

    programs.nushell = {
      enable = true;
      extraConfig = ''
      '';
      shellAliases = {
        nix-search = "nix --extra-experimental-features \"nix-command flakes\" search";
      };
    };

    programs.plasma = {
      enable = true;

      powerdevil = {
        AC = {
          autoSuspend = {
            action = "nothing";
          };
        };
      };
    };

    programs.git = {
      enable = true;
      userName = "Nico Vergara";
      userEmail = "me@nicoevergara.com";
    };

    programs.starship.enable = true;

    home.stateVersion = "24.11"; # Do not modify without reading changelogs
  };
}
