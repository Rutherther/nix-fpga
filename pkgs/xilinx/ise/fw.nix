{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  name = "xilinx-jtag-fw";
  phases = ["unpackPhase" "installPhase"];
  src = ./fw;
  installPhase = ''
    mkdir -p $out/share $out/etc/hotplug/usb/xusbdfwu.fw
    cp * $out/share/
    cp * $out/etc/hotplug/usb/xusbdfwu.fw/
  '';
}
