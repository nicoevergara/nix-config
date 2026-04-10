{
  lib,
  isDarwin ? false,
  ...
}:
let
  modulesRootPath = ../../..;
in
{
  imports = [
    "${modulesRootPath}/modules/home-manager/base.nix"
    "${modulesRootPath}/modules/home-manager/devenv.nix"
  ]
  ++ lib.optionals isDarwin [ ./darwin.nix ]
  ++ lib.optionals (!isDarwin) [ ./linux.nix ];

  home.stateVersion = "25.11";
}
