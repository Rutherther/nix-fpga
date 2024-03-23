{ pkgs, myLib, ise-fw, ise-usb-driver, ... }:

myLib.finalPkgGenerator.override {
  mainProgram = "ise";

  fhsEnv = pkgs.callPackage ./fhs.nix { inherit myLib ise-fw ise-usb-driver; requireInstallDir = true; };

  executables = [
    # TODO
    "ise"
    "xflow"
    "impact"
  ];
}
