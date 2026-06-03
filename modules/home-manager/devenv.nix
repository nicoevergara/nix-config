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
        extensions = [
          "nix"
          "nil"
          "docker"
        ];
      };

      neovim = {
        enable = true;
        withRuby = false;
        withPython3 = false;
        initLua = builtins.readFile ../neovim/settings.lua;
        extraPackages = with unstable-pkgs; [
          # nix-related pkgs
          nil
          nixfmt
          # lua-related pkgs
          stylua
          lua-language-server
          # rust-related pkgs
          rustfmt
          # python-related pkgs
          ty
          ruff
          # typescript/javascript-related pkgs
          typescript
          typescript-language-server
          # telescope dependencies (live_grep / find_files)
          ripgrep
          fd
        ];
        plugins = with unstable-pkgs.vimPlugins; [
          dropbar-nvim
          nvim-lspconfig
          lazydev-nvim
          blink-cmp
          conform-nvim
          neo-tree-nvim
          mini-icons
          catppuccin-nvim
          plenary-nvim
          telescope-nvim
          telescope-fzf-native-nvim
          claudecode-nvim
          (nvim-treesitter.withPlugins (p: [
            p.nix
            p.rust
            p.lua
            p.python
            p.typescript
            p.javascript
            p.tsx
          ]))
        ];
      };

      direnv = {
        enable = true;
        enableNushellIntegration = true; # see note on other shells below
        nix-direnv.enable = true;
      };

      nushell = {
        enable = true;
        extraConfig = builtins.readFile ../shells/configs/nushell/config.nu;
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
