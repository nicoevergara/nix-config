{
  lib,
  stable-pkgs,
  unstable-pkgs,
  isDarwin ? false,
  ...
}:
let
  nix-lang-packages = with unstable-pkgs; [
    nixfmt
    nil
    nixd
    statix
    deadnix
  ];
  ai-tooling-packages = with unstable-pkgs; [
    gemini-cli
    claude-code
  ];
  infra-packages = with stable-pkgs; [
    protobuf
    postgresql
  ];

  linux-only-programs = {
    programs = {
      ghostty = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          command = "${stable-pkgs.zsh}/bin/zsh";
        };
      };
    };
  };

  general-programs = {
    home.packages = nix-lang-packages ++ ai-tooling-packages ++ infra-packages;

    programs = {
      zed-editor = {
        enable = true;
        userSettings = {
          terminal.shell.program = "${stable-pkgs.zsh}/bin/zsh";
        };
        extensions = [ "nix" ];
      };

      direnv = {
        enable = true;
        enableZshIntegration = true; # see note on other shells below
        nix-direnv.enable = true;
      };

      zsh = {
        enable = true;
      };

      git = {
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
      vim = {
        enable = true;
        settings = {
          tabstop = 2;
        };
      };
      starship.enable = true;
    };
  };
in
lib.mkMerge [
  general-programs
  (lib.mkIf (!isDarwin) linux-only-programs)
]
