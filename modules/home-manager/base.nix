{
  unstable-pkgs,
  ...
}:
{
  home.packages = with unstable-pkgs; [
    spotify
    zoom-us
  ];

  programs = {
    anki.enable = true;
  };
}
