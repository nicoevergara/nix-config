{
  pkgs,
  unfree-pkgs-unstable,
  ...
}:
let
  nix-lang-packages = with pkgs; [
    alejandra
    nil
    nixd
  ];
  ai-tooling-packages =
    with pkgs;
    [
      gemini-cli
    ]
    ++ (with unfree-pkgs-unstable; [
      claude-code
    ]);
  infra-packages = with pkgs; [
    protobuf
    postgresql
  ];
in
(nix-lang-packages ++ ai-tooling-packages ++ infra-packages)
