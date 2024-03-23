{ pkgs, lib, myLib, licenseInterface ? "" }:

let
  fhs = pkgs.callPackage ./fhs.nix {  inherit myLib licenseInterface; };
in pkgs.writeShellScriptBin "questa-shell" ''
  exec ${lib.getExe fhs} bash "$@"
''
