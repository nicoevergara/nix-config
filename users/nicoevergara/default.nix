{
  pkgs,
  config,
  lib,
  ...
}: {
  users.mutableUsers = true;
  users.users.nicoevergara = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "libvirtd"
    ];

    packages = [pkgs.home-manager];

    openssh.authorizedKeys.keys = [];
  };

  home-manager.users.nicoevergara = import ./home-manager/home.nix;
}
