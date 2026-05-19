{
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
    ];
  };
}
