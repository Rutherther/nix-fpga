{ pkgs, lib, myLib, ise-fw, ise-usb-driver, ... }:

let
  fhs = pkgs.callPackage ./fhs.nix {  inherit myLib ise-fw ise-usb-driver; };
in pkgs.writeShellScriptBin "ise-shell" ''
  exec ${lib.getExe fhs} bash "$@"
''
