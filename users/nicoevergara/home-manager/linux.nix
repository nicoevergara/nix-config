{
  stable-pkgs,
  username,
  unstable-pkgs,
  ...
}:
{
  home.packages =
    (with stable-pkgs; [
      libreoffice-qt6-fresh
      calibre
      filen-cli
      texliveSmall
      fuse3
      nmap
      usbutils
      xclip
      proton-pass
      virt-manager
      fastfetch
      lsof
    ])
    ++ (with unstable-pkgs; [
      chromium
      firefox
    ]);

  systemd.user.timers.filen-sync = {
    Unit.Description = "A systemd timer for filen syncing";
    Timer = {
      OnStartupSec = "1min";
      OnUnitActiveSec = "30min";
      Unit = "filen-sync.service";
    };
    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.services.filen-sync = {
    Unit = {
      Description = "Sync with Filen using filen-cli sync";
      After = [ "network.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${stable-pkgs.filen-cli}/bin/filen sync /home/${username}/Documents:/";
    };
  };
}
