{ pkgs, lib, myLib }:

let
  fhs = pkgs.callPackage ./fhs.nix {  inherit myLib; };
in pkgs.writeShellScriptBin "vivado-shell" ''
  exec ${lib.getExe fhs} bash "$@"
''
