{
  config,
  lib,
  pkgs,
  ...
}:
let
  calibre-library-dir = "/var/lib/calibre-server";
  service-user = "nicoevergara";
  calibre-server-user = "calibre-server";
in {
  systemd.tmpfiles.rules = [
    "d ${calibre-library-dir} 0755 calibre-server calibre-server -"
  ];

  services.calibre-server = {
    enable = true;
    auth = {
      enable = true;
      userDb = "/srv/calibre/users.sqlite";
    };
    libraries = [ calibre-library-dir ];
  };
}
