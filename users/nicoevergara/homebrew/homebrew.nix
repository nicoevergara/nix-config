{
  username,
  ...
}:
let
  general-pkgs = [
    "brainfm"
    "whatsapp"
    "betterdisplay"
    "proton-meet"
    "proton-mail"
    "protonvpn"
    "filen"
    "whatsapp"
    "betterdisplay"
    "rectangle-pro"
  ];

  browser-pkgs = [
    "zen"
  ];

  dev-pkgs = [
    "google-gemini"
    "claude"
    "tableplus"
    "docker-desktop"
    "ghostty"
  ];

in
{
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    autoMigrate = true;
    user = username;
  };

  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
    };
    casks = general-pkgs ++ browser-pkgs ++ dev-pkgs;
  };
}
