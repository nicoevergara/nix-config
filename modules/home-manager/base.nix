{
  stable-pkgs,
  unstable-pkgs,
  ...
}:
{
  home.packages = [
    unstable-pkgs.spotify
    unstable-pkgs.zoom-us
  ];

  programs = {
    anki.enable = true;
  };
}
