{
  pkgs,
  unfree-pkgs,
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
    ++ (with unfree-pkgs; [
      claude-code
    ]);
  infra-packages = with pkgs; [
    protobuf
    postgresql
  ];
in
(nix-lang-packages ++ ai-tooling-packages ++ infra-packages)
