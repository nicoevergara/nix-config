{
  config,
  pkgs,
  ...
}: (with pkgs;
  [
    alejandra
    git
    kubectl
    go-swagger
    protobuf
    delve
    go
  ]
  ++ [
    (
      with pkgs.google-cloud-sdk;
        withExtraComponents [
          components.gke-gcloud-auth-plugin
          components.cloud-sql-proxy
        ]
    )
  ])
