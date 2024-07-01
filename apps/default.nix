{ pkgs, ... }: rec {
  # Format and install from nothing
  installer = import ./installer.nix { inherit pkgs; };
}