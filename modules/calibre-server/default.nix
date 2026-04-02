{
  config,
  lib,
  pkgs,
  serviceMembers,
  ...
}:
let
  calibre-library-dir = "/var/lib/calibre-server";
  calibre-server-user = "calibre-server";
in
{

  users.groups.calibre-server.members = [
    calibre-server-user
  ]
  ++ serviceMembers;
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
