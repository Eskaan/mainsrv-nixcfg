{ config, lib, pkgs, settings, ... }:

{
  imports =
    [
      ../../system/hardware-configuration.nix
    ];

  # Use the systemd-boot loader.
  boot.loader.systemd-boot.enable = (settings.system.bootMode == "uefi");
  boot.loader.grub.enable = (settings.system.bootMode == "bios");
  boot.loader.grub.version = 2;
  #boot.loader.grub.device = settings.system.grubDevice;
  
  networking.hostName = "mainsrv";

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de-latin1";
  };

  users.mutableUsers = false;
  users.users.eskaan = {
    isNormalUser = true;
    extraGroups = [ "wheel" "minecraft" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC1T14GbpTsDZU2RJR0ES1oy6xI1xnUZvQKoCeLt8I1mEgVJyTxvUeMrqYI3OGKWFfh/M7SK8Z7gNJ4YLL1U0qrOPeFk1MU/p9tgZaR4x09D3dwxrpcu+RLxurWnSOACU32aY/YK0Ao6pHeIfc1vOLHg+mz8mA695cfvbrIdTewo4SoYOOJBTan416Fy9BapqEe5Zjk7gva137DQ1g6M1nyVoJpcVAHk1/luwmvEfseamOVv5utNMcq2edms0cqMhe2J8KGhHOwxRYyYmrX/t1ApNHaPti0yMw3cO37BR47Hk+GCiMlKF0kSjptaLDaogvb8G9g+w3cp+a1FLxYTBma+wyZ759bS0V4tKCEkJbR84rBxVy1wUukidqrFCWzhKj6oFSuGtSjnqNa0JDyEuQPv90L4NPKYgCRsudIyf7QuNAc2m6bTfq5K84b8p86w8Nq6UbdY+wyxgSnKszro9id6JODBF3OkDJqQ3pkhXChz82rxtXAN1rcbg9MU4exPHA/x0Perpq9lPQLNXfZPzfCC1s7DPf7tO/twtXnzGBvmyUVan10IYDfNwstXkGzMZOcEVnm2xK88ZbyuceTsI2many/cH36m6mhF4OEQoYB8FL09K7XCrGyO5R01HdVRSIswmFy5DAQRhhXmEABa71z1CJI+jmvyUuZ5ULN8zSuQQ== eskaan"
    ];
    hashedPassword = "$y$j9T$5E6UVJk4GH6KeajVqt2QI1$QWRZP7RYlOYAm5p6rVagPbsbcXhSKcfXx5ltni0.Eu.";
    packages = with pkgs; [
      stress
      macchina
      dmidecode
    ];
  };
  users.groups.minecraft = {};
  users.users.minecraft = {
    isSystemUser = true;
    group = "minecraft";
    home = "/home/minecraft";
    homeMode = "770";
    packages = with pkgs; [
      temurin-jre-bin
      tmux
    ];
  };

  environment.systemPackages = with pkgs; [
    # Base / essentials
    neovim
    wget
    curl
    git

    # Sensors and monitors
    htop
    lm_sensors
    i2c-tools
    hdparm
    smartmontools
    amdctl
    linuxPackages.cpupower
    ethtool

    # Backup drives
    linuxPackages.zfs
  ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  programs = {
    bash = {
      shellAliases = {
        vim = "nvim";
        e = "exit";
        c = "clear";
	      rb = "nixos-rebuild switch --flake ./#mainsrv";
      };
    };
    git = {
      enable = true;
      config = {
        user = {
	        name = "Eskaan";
	        email = "github@eskaan.de";
	      };
        init = {
          defaultBranch = "main";
        };
      };
    };
    neovim = {
      configure = ''
        set tabstop=2
        set expandtab
      '';
      defaultEditor = true;
    };
  };

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 25565 ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  # First installed version for legacy reasons (do not change).
  system.stateVersion = "23.11";
}

