{
  stable-pkgs,
  unstable-pkgs,
  ...
}:
let
  nix-lang-packages = with unstable-pkgs; [
    nixfmt
    nil
    nixd
  ];
  ai-tooling-packages = with unstable-pkgs; [
    gemini-cli
    claude-code
  ];
  infra-packages = with stable-pkgs; [
    protobuf
    postgresql
  ];
in
{
  home.packages = nix-lang-packages ++ ai-tooling-packages ++ infra-packages;

  programs.zed-editor = {
    enable = true;
    userSettings = {
      terminal.shell.program = "${stable-pkgs.zsh}/bin/zsh";
    };
    extensions = [ "nix" ];
  };

  programs.ghostty = {
    enable = false;
    enableZshIntegration = true;
    settings = {
      command = "${stable-pkgs.zsh}/bin/zsh";
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true; # see note on other shells below
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Nico Vergara";
        email = "me@nicoevergara.com";
      };
      extraConfig = {
        push.autoSetupRemote = true;
        core = {
          editor = "vim";
        };
      };
    };
    ignores = [
      "*.DS_Store"
      ".direnv"
    ];
  };

  programs.vim = {
    enable = true;
    settings = {
      tabstop = 2;
    };
  };

  programs.starship.enable = true;
}
