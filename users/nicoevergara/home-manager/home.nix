{
  config,
  pkgs,
  unstable-pkgs,
  unfree-pkgs,
  unfree-pkgs-unstable,
  username,
  ...
}:
let
  modulesRootPath = ../../..;
in
{
  home.packages =
    import "${modulesRootPath}/modules/home-manager/devenv.nix" {
      inherit pkgs unfree-pkgs config;
    }
    ++ (with pkgs; [
      anki
      libreoffice-qt6-fresh
      filen-cli
      texliveSmall
      fuse3
      nmap
      usbutils
      xclip
      calibre
      proton-pass
      virt-manager
      neofetch
      lsof
    ])
    ++ (with pkgs.kdePackages; [
      partitionmanager
    ])
    ++ (with unfree-pkgs-unstable; [
      spotify
      zoom-us
    ])
    ++ (with unstable-pkgs; [
      chromium
      firefox
    ]);

  imports = [
    "${modulesRootPath}/modules/home-manager/base.nix"
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
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.services.filen-sync = {
    Unit = {
      Description = "Sync with Filen using filen-cli sync";
      After = [ "network.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.filen-cli}/bin/filen sync /home/${username}/Documents:/
      '';
    };
  };

  programs = {
    # nushell = {
    #   enable = true;
    #   configFile.source = (builtins.toString ./.) + "/configs/nushell/config.nu";
    #   shellAliases = {
    #     nix-search = "nix --extra-experimental-features \"nix-command flakes\" search";
    #   };
    # };

    plasma = {
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
          { layout = "us"; }
          { layout = "tr"; }
        ];
      };
    };

    vim = {
      enable = true;
      settings = {
        tabstop = 2;
      };
    };

    starship.enable = true;

    zed-editor = {
      enable = true;
      package = unstable-pkgs.zed-editor;
      userSettings = {
        terminal = {
          shell = {
            program = "${pkgs.zsh}/bin/zsh";
          };
        };
      };
    };
  };

  home.stateVersion = "25.11"; # Do not modify without reading changelogs
}
