{
  config,
  pkgs,
  unstable-pkgs,
  lib,
  username,
  ...
}: {
  nixpkgs.config.allowUnfree = true;
  home.packages =
    (with pkgs; [
      anki
      zoom-us
      libreoffice-qt6-fresh
      chromium
      fuse3
      alejandra
      nmap
      git
      usbutils
      xclip
      calibre
      spotify
      virt-manager
    ])
    ++ (
      with pkgs.kdePackages; [
        partitionmanager
      ]
    )
    ++ (
      with unstable-pkgs; [
        unstable-pkgs.filen-cli
      ]
    );

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
        ${unstable-pkgs.filen-cli}/bin/filen sync /home/${username}/Documents:/
      '';
    };
  };

  programs.nushell = {
    enable = true;
    configFile.source = (builtins.toString ./.) + "/configs/nushell/config.nu";
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

    input.keyboard = {
      layouts = [
        {layout = "us";}
        {layout = "tr";}
      ];
    };
  };

  programs.git = {
    enable = true;
    userName = "Nico Vergara";
    userEmail = "me@nicoevergara.com";
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacs;
    extraPackages = epkgs:
      with epkgs; [
        doom
      ];
  };

  programs.vim = {
    enable = true;
    settings = {
      tabstop = 2;
    };
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu+ssh://nicoevergara@192.168.0.84/system"];
      uris = ["qemu+ssh://nicoevergara@192.168.0.84/system"];
    };
  };

  programs.starship.enable = true;

  home.stateVersion = "24.11"; # Do not modify without reading changelogs
}
