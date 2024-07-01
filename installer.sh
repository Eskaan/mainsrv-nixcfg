#!/bin/sh
set -e

# Install my nixos dotfiles

# Clone dotfiles
if [ $# -gt 0 ]
  then
    echo "Using given location: $1"
    SCRIPT_DIR=$1
  else
    echo "Using default location: ~/.dotfiles"
    SCRIPT_DIR=~/.dotfiles
fi

if [ ! -d "$SCRIPT_DIR" ]; then
  echo "Cloning repository to $SCRIPT_DIR"
  nix-shell -p git --command \
    "git clone https://github.com/eskaan/dotfiles.git \"$SCRIPT_DIR\""

  echo "Generate hardware config for new system"
  nixos-generate-config --no-filesystems --show-hardware-config > $SCRIPT_DIR/system/hardware-configuration.nix

  # Check if uefi or bios
  if [ -d /sys/firmware/efi/efivars ]; then
      sed -i "0,/bootMode.*=.*\".*\";/s//bootMode = \"uefi\";/" $SCRIPT_DIR/settings.nix
      echo "Installing in UEFI mode"
  else
      echo "Installing in BIOS mode"
      sed -i "0,/bootMode.*=.*\".*\";/s//bootMode = \"bios\";/" $SCRIPT_DIR/settings.nix
      grubDevice=$(findmnt / | awk -F' ' '{ print $2 }' | sed 's/\[.*\]//g' | tail -n 1 | lsblk -no pkname | tail -n 1 )
      sed -i "0,/grubDevice.*=.*\".*\";/s//grubDevice = \"\/dev\/$grubDevice\";/" $SCRIPT_DIR/settings.nix
  fi

  #echo "Patch flake.nix with different username/name and remove email by default"
  #sed -i "0,/emmet/s//$(whoami)/" $SCRIPT_DIR/flake.nix
  #sed -i "0,/Emmet/s//$(getent passwd $(whoami) | cut -d ':' -f 5 | cut -d ',' -f 1)/" $SCRIPT_DIR/flake.nix
  #sed -i "s/emmet@librephoenix.com//" $SCRIPT_DIR/flake.nix
  #sed -i "s+~/.dotfiles+$SCRIPT_DIR+g" $SCRIPT_DIR/flake.nix

  echo "Opening editor to manually edit settings before install"
  if [ -z "$EDITOR" ]; then
      EDITOR=nano;
  fi
  $EDITOR "$SCRIPT_DIR/settings.nix"
fi

echo "Warning: This script will completely overwrite the following disks!"
nix --experimental-features "nix-command flakes" eval --impure --expr "let settings = import \"$SCRIPT_DIR/settings.nix\"; in settings.system.disks"
echo -n "Install now? [y/N]"
read -n 1 RET
echo
if [[ "$RET" == "y" ]]; then
  echo "Continuing with installation"
else
  echo "Aborting..."
  exit 0
fi

echo "Running disko"
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko --flake "path:$SCRIPT_DIR#disko"

echo "Installing system"
sudo nixos-install --flake "path:$SCRIPT_DIR#system"


# Permissions for files that should be owned by root
#sudo $SCRIPT_DIR/harden.sh $SCRIPT_DIR;

# Rebuild system
#sudo nixos-rebuild switch --flake $SCRIPT_DIR#system

# Install and build home-manager configuration
#nix run home-manager/master --experimental-features "nix-command flakes" -- switch --flake $SCRIPT_DIR#user