{
  pkgs,
  ...
}:
let
  nix-lang-packages = with pkgs; [
    alejandra
    nil
    nixd
  ];
  ai-tooling-packages = with pkgs; [
    claude-code
    gemini-cli
  ];
  go-packages = with pkgs; [
    delve
    go-swagger
    (go-migrate.overrideAttrs (oldAttrs: {
      tags = [ "postgres" ];
    }))
  ];
  infra-packages = with pkgs; [
    kubectl
    protobuf
    postgresql
    tenv
    avro-tools
    (
      with pkgs.google-cloud-sdk;
      withExtraComponents [
        components.gke-gcloud-auth-plugin
        components.cloud-sql-proxy
        components.pubsub-emulator
      ]
    )
  ];
in
(nix-lang-packages ++ ai-tooling-packages ++ go-packages ++ infra-packages)
