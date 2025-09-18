{
  config,
  pkgs,
  ...
}: let
  go-packages = with pkgs; [
    delve
    go
    go-swagger
    (
      go-migrate.overrideAttrs
      (oldAttrs: {
        tags = ["postgres"];
      })
    )
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
        ]
    )
  ];
in (
  with pkgs;
    [
      alejandra
      git
      idris2
      python314
    ]
    ++ go-packages
    ++ infra-packages
)
