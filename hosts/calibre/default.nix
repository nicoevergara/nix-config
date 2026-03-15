{
  config,
  lib,
  pkgs,
  ...
}: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    if ! blkid /dev/vdb >/dev/null 2>&1; then
        mkfs.ext4 -L data /dev/vdb
    fi
  '';

  networking.hostName = "calibre";
  networking.interfaces.eth0.useDHCP = true;

  # Enable SSH
  services.openssh.enable = true;

  # User accounts
  users.users.calibre-user = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    initialPassword = "password"; # Set a secure password
  };

  environment.systemPackages = with pkgs; [
    calibre
    neofetch
  ];

  services.calibre-server = {
    enable = true;
  };

  systemd.tmpfiles.settings = {
    "calibre-server-library" = {
      "/var/lib/calibre-server" = {
        d = {
          group = "user";
          mode = "0755";
          user = "calibre-user";
        };
      };
    };
  };

  virtualisation = {
    vmVariant = {
      virtualisation = {
        memorySize = 4096;
        cores = 2;
        diskSize = 20480;
        fileSystems."/data" = {
          device = "/dev/disk/by-label/data";
          fsType = "ext4";
        };
        emptyDiskImages = [20480];
      };
    };
  };

  # Allow remote updates (optional, for convenience)
  nix.settings.trusted-users = ["root" "@wheel"];
  nix.settings.experimental-features = ["nix-command" "flakes"];

  system.stateVersion = "25.05";
}
