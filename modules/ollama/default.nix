{
  config,
  pkgs,
  ...
}:
let
  mongodbConfig = {
    port = 27017;
  };
  ollamaConfig = {
    host = "127.0.0.1";
    port = 11434;
    defaultModels = [ "qwen2.5vl:3b" ];
  };
  librechatConfig = {
    host = "0.0.0.0";
    port = 3080;
    podname = "librechat-pod";
    serviceConfigFile = (pkgs.formats.yaml { }).generate "librechat.yaml" {
      version = "1.3.6";
      endpoints = {
        custom = [
          {
            name = "Ollama";
            baseURL = "http://${ollamaConfig.host}:${toString ollamaConfig.port}/v1/";
            apiKey = "ollama";
            models = {
              default = ollamaConfig.defaultModels;
              fetch = true;
            };
          }
        ];
      };
    };
  };
  meiliConfig = {
    port = 7700;
    masterKey = "your_super_secret_key_12345";
  };
in
{

  virtualisation = {
    oci-containers.containers = {
      mongodb = {
        image = "mongo:latest";
        extraOptions = [ "--pod=${librechatConfig.podname}" ];
        environment = {
          # MONGO_INITDB_ROOT_USERNAME = "admin";
          # MONGO_INITDB_ROOT_PASSWORD = "password";
        };
        volumes = [
          "/var/lib/mongodb:/data/db"
        ];
      };

      meilisearch = {
        image = "getmeili/meilisearch:latest";
        extraOptions = [ "--pod=${librechatConfig.podname}" ];
        environment = {
          MEILI_HOST = "0.0.0.0:${toString meiliConfig.port}";
          MEILI_NO_ANALYTICS = "true";
          # Set a master key for security (use a strong string)
          MEILI_MASTER_KEY = meiliConfig.masterKey;
        };
        volumes = [ "/var/lib/meilisearch:/meili_data" ];
      };

      librechat = {
        image = "ghcr.io/danny-avila/librechat-dev:latest";
        extraOptions = [ "--pod=${librechatConfig.podname}" ];
        environment = {
          HOST = librechatConfig.host;
          PORT = toString librechatConfig.port;

          MONGO_URI = "mongodb://127.0.0.1:${toString mongodbConfig.port}/LibreChat";

          # Meilisearch Integration
          SEARCH = "true";
          MEILI_HOST = "http://127.0.0.1:${toString meiliConfig.port}";
          MEILI_MASTER_KEY = meiliConfig.masterKey;

          # Reference your local Ollama server dynamically
          OLLAMA_BASE_URL = "http://${config.services.ollama.host}:${toString config.services.ollama.port}";

          CREDS_KEY = "f34e6c384e11a3d6a9f5d6f3e3e3e3e3"; # 32 characters
          CREDS_IV = "1234567890abcdef1234567890abcdef"; # 32 characters
          JWT_SECRET = "something_very_secret_and_long";
          JWT_REFRESH_SECRET = "another_very_secret_and_long_string";
        };

        volumes = [
          "${librechatConfig.serviceConfigFile}:/app/librechat.yaml:ro"
          # "/var/lib/librechat/data:/app/api/data"
        ];
      };

      ollama = {
        image = "ollama/ollama:latest";
        extraOptions = [
          "--pod=${librechatConfig.podname}"
          "--device=nvidia.com/gpu=all"
          "--shm-size=6g"
        ];
        volumes = [ "/var/lib/ollama:/root/.ollama" ];
      };
    };
  };

  # Create directories for data persistence
  systemd.tmpfiles.rules = [
    "d /var/lib/mongodb 0755 root root -"
    "d /var/lib/meilisearch 0755 root root -"
  ];

  systemd.services.init-librechat-pod = {
    description = "Create the Podman pod for LibreChat stack";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      # Create the pod if it doesn't exist
      ${pkgs.podman}/bin/podman pod exists ${librechatConfig.podname} || \
      ${pkgs.podman}/bin/podman pod create \
        --name ${librechatConfig.podname} \
        --publish ${toString librechatConfig.port}:${toString librechatConfig.port} \
        --publish ${toString meiliConfig.port}:${toString meiliConfig.port}
    '';
  };

  systemd.services.podman-ollama.path = [ pkgs.nvidia-container-toolkit ];

  systemd.services = {
    "podman-mongodb".after = [ "init-librechat-pod.service" ];
    "podman-meilisearch".after = [ "init-librechat-pod.service" ];
    "podman-librechat" = {
      after = [
        "init-librechat-pod.service"
        "podman-mongodb.service"
        "podman-meilisearch.service"
        "podman-ollama.service"
      ];
      requires = [
        "podman-mongodb.service"
        "podman-meilisearch.service"
        "podman-ollama.service"
      ];
    };
  };
}
