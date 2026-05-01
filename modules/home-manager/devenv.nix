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
          command = "${stable-pkgs.nushell}/bin/nu";
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
          terminal.shell.program = "${stable-pkgs.nushell}/bin/nu";
        };
        extensions = [ "nix" ];
      };

      neovim = {
        enable = true;
        withRuby = false;
        withPython3 = false;
      };

      direnv = {
        enable = true;
        enableNushellIntegration = true; # see note on other shells below
        nix-direnv.enable = true;
      };

      nushell = {
        enable = true;
      };

      git = {
        enable = true;
        settings = {
          user = {
            name = "Nico Vergara";
            email = "me@nicoevergara.com";
          };
          push.autoSetupRemote = true;
          core = {
            editor = "nvim";
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

    home.file.".config/ghostty/config.ghostty".source = ../ghostty/config.ghostty;
  };
in
lib.mkMerge [
  general-programs
  (lib.mkIf (!isDarwin) linux-only-programs)
]
