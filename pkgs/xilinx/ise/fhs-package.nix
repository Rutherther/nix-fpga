{ pkgs, myLib, ise-fw, ... }:

myLib.finalPkgGenerator.override {
  mainProgram = "ise";

  fhsEnv = pkgs.callPackage ./fhs.nix {  inherit myLib ise-fw; };

  executables = [
    # TODO
    "ise"
    "xflow"
    "impact"
  ];
}
