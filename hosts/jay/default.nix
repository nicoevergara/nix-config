{
  config,
  lib,
  pkgs,
  ...
}:
let
  usernames = {
    nico = "nicoevergara";
  };
in
{
  imports = [
    ./hardware-configuration.nix
    ../../users/${usernames.nico}
    ../../modules/ollama
  ]
  ++ [
    (import ../../modules/calibre-server {
      inherit config pkgs lib;
      serviceMembers = [ usernames.nico ];
    })
  ];

  # Enable UEFI boot loader
  boot.loader.systemd-boot.enable = true;

  networking = {
    hostName = "jay";
    networkmanager.enable = true;
    # Enable NAT
    nat = {
      enable = true;
      externalInterface = "enp0s31f6";
      internalInterfaces = [ "wg0" ];
    };

    firewall = {
      allowedTCPPorts = [
        80
        53
      ];
      allowedUDPPorts = [ 51820 ];
    };

    wireguard.interfaces = {
      wg0 = {
        ips = [ "10.100.0.1/24" ];
        listenPort = 51820;
        # Allow internet forwarding and disable LAN access
        # The DNS server on the clients need to be set for this to work
        postSetup = ''
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
          ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -d 192.168.0.0/16 -j DROP
          ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -d 10.0.0.0/8 -j DROP
          ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -d 10.0.0.0/8 -j DROP
          ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -d 172.16.0.0/12 -j DROP
          ${pkgs.iptables}/bin/iptables -A INPUT -i wg0 -p udp --dport 53 -j ACCEPT
          ${pkgs.iptables}/bin/iptables -A INPUT -i wg0 -p tcp --dport 53 -j ACCEPT
        '';

        # This undoes the above command
        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
          ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -d 192.168.0.0/16 -j DROP
          ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -d 10.0.0.0/8 -j DROP
          ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -d 172.16.0.0/12 -j DROP
          ${pkgs.iptables}/bin/iptables -D INPUT -i wg0 -p udp --dport 53 -j ACCEPT
          ${pkgs.iptables}/bin/iptables -D INPUT -i wg0 -p tcp --dport 53 -j ACCEPT
        '';

        privateKeyFile = "/private/wireguard_key";
        peers = [
          {
            name = "nicos-iphone";
            publicKey = "UGfMEYJMpWH/n5lHMFIG2PpvJdRJiCJw3TVTedaUblE=";
            allowedIPs = [ "10.100.0.2/32" ];
          }
          {
            name = "emmys-iphone";
            publicKey = "1l7/cFMXuRRz67z1YxGZcobVCGpvVU0Z13OwxdTmdHE=";
            allowedIPs = [ "10.100.0.3/32" ];
          }
          {
            name = "emmys-macbook";
            publicKey = "/LE475Ft8b7aypMjFwpwtbO5mgUNZDmXJKcF27TY4B4=";
            allowedIPs = [ "10.100.0.4/32" ];
          }
          {
            name = "gl-inet-travel-router";
            publicKey = "H+whubq9mvTPsMu3HAFzvvJT4rGhkfzTxhfhdX05DGo=";
            allowedIPs = [ "10.100.0.5/32" ];
          }
        ];
      };
    };
  };

  environment.etc."blocked-hosts".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/StevenBlack/hosts/c66c4aa05a95669943eb3b8f68ba3d359825c4b9/hosts";
    sha256 = "13m33rfx5rg3n6h8p2wk7qpzpi159dkdnp0jchk46r3v6iv4vnh6";
  };

  services.avahi = {
    enable = true;
  };

  services.dnsmasq = {
    enable = true;
    settings = {
      # DNS mappings to self-hosted services
      address = [
        "/vergara.casa/10.100.0.1"
        "/library.vergara.casa/10.100.0.1"
      ];
      addn-hosts = [
        "/etc/blocked-hosts"
      ];
      interface = "wg0";
      listen-address = [
        "10.100.0.1"
        "127.0.0.1"
      ];
      bind-interfaces = true;
      server = [
        "1.1.1.1"
        "1.0.0.1"
      ];
    };
  };

  # set up reverse proxy for calibre
  services.nginx = {
    enable = true;
    user = usernames.nico;
    virtualHosts = {
      "library.vergara.casa" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8080";
          proxyWebsockets = true;
        };
        listen = [
          {
            addr = "10.100.0.1";
            port = 80;
          }
        ];
      };
    };
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable KDE 6
  services.displayManager.sddm = {
    enable = true;
    wayland = {
      enable = true;
    };
  };

  # Enable xwayland for X11 app support
  programs.xwayland.enable = true;

  services.desktopManager.plasma6 = {
    enable = true;
  };

  # Enable sound.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Packages included in system profile
  environment.systemPackages = with pkgs; [
    vim
    wget
    wireguard-tools
    calibre
  ];

  # Set session variable for Chrome-based apps to work with Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      AllowUsers = null;
      PermitRootLogin = "no";
    };
  };

  # Set up virtualization with libvirtd and virt-manager
  programs.virt-manager.enable = true;

  # Set user groups' members
  users.groups.libvirtd.members = [ usernames.nico ];

  virtualisation = {
    oci-containers = {
      backend = "podman";
    };

    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
      };
    };

    spiceUSBRedirection.enable = true;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "25.11";
  system.autoUpgrade.enable = true;
}
