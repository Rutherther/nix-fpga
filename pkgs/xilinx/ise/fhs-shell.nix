{ pkgs, lib, myLib, ise-fw, ... }:

let
  fhs = pkgs.callPackage ./fhs.nix {  inherit myLib ise-fw; };
in pkgs.writeShellScriptBin "ise-shell" ''
  exec ${lib.getExe fhs} bash "$@"
''
