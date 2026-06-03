{
  username,
  ...
}:{
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
    casks = [
      "ghostty"
      "filen"
      "whatsapp"
      "claude"
      "betterdisplay"
      "protonvpn"
      "brainfm"
      "proton-meet"
      "rectangle-pro"
      "google-gemini"
      "tableplus"
      "docker-desktop"
    ];
  };
}
