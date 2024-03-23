{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  name = "xilinx-jtag-fw";
  phases = ["unpackPhase" "installPhase"];
  src = ./fw;
  installPhase = ''
    mkdir -p $out/share
    cp * $out/share/
  '';
}
