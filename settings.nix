{
  # ---- SYSTEM SETTINGS ---- #
  system = {
    system = "x86_64-linux"; # system arch
    hostname = "snowfire"; # hostname
    profile = "personal"; # select from profiles directory
    useStable = true;
    timezone = "Europe/Berlin"; # select timezone
    locale = "en_US.UTF-8"; # select locale
    disks = {
      # Disks used for disko config
      # Options may depend on profile
      main = "/dev/by-id/nvme-WD_Green_SN350_2TB_224805467712";
      backup = "/dev/by-id/ata-TOSHIBA_MQ01ACF050_16TLC6DRT";
    };
    bootMode = "uefi"; # Boot mode, uefi or bios
    grubDevice = ""; # Grub device, only needed for BIOS
  };

  # ----- USER SETTINGS ----- #
  user = rec {
    username = "eskaan"; # username
    name = "Eskaan"; # name/identifier
    email = "eskaan@eskaan.de"; # email (used for certain configurations)
    dotfilesDir = "~/.dotfiles"; # absolute path of the local repo
    theme = "io"; # selcted theme from my themes directory (./themes/)
    wm = "hyprland"; # Selected window manager or desktop environment; must select one in both ./user/wm/ and ./system/wm/
    # window manager type (hyprland or x11) translator
    wmType = if (wm == "hyprland") then "wayland" else "x11";
    browser = "librewolf"; # Default browser; must select one from ./user/app/browser/
    term = "alacritty"; # Default terminal command;
    font = "Intel One Mono"; # Selected font
    #fontPkg = pkgs.intel-one-mono; # Font package
    editor = "vim"; # Default editor;
  };
}