{ pkgs, lib, myLib, licenseInterface ? "" }:

let
  fhs = pkgs.callPackage ./fhs.nix {  inherit myLib licenseInterface; };
in pkgs.writeShellScriptBin "diamond-shell" ''
  exec ${lib.getExe fhs} bash "$@"
''
