{ pkgs, ... }: {
  type = "app";

  program = builtins.toString (
    pkgs.writeShellScript "installer" (builtins.readFile ../installer.sh)
  );
}