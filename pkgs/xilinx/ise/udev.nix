{ lib, pkgs, fxload, ise-fw, ... }:

pkgs.writeTextFile {
  name = "ise-udev-rules";
  destination = "/etc/udev/rules.d/05-xilinx-ise.rules";
  text = ''
    # version 0003
    ATTRS{idVendor}=="03fd", ATTRS{idProduct}=="0008", MODE="666"
    SUBSYSTEM=="usb", ACTION=="add", ATTRS{idVendor}=="03fd", ATTRS{idProduct}=="0007", RUN+="${lib.getExe fxload} -v -t fx2 -i ${ise-fw}/share/xusbdfwu.hex -d $tempnode"
    SUBSYSTEM=="usb", ACTION=="add", ATTRS{idVendor}=="03fd", ATTRS{idProduct}=="0009", RUN+="${lib.getExe fxload} -v -t fx2 -i ${ise-fw}/share/xusb_xup.hex -d $tempnode"
    SUBSYSTEM=="usb", ACTION=="add", ATTRS{idVendor}=="03fd", ATTRS{idProduct}=="000d", RUN+="${lib.getExe fxload} -v -t fx2 -i ${ise-fw}/share/xusb_emb.hex -d $tempnode"
    SUBSYSTEM=="usb", ACTION=="add", ATTRS{idVendor}=="03fd", ATTRS{idProduct}=="000f", RUN+="${lib.getExe fxload} -v -t fx2 -i ${ise-fw}/share/xusb_xlp.hex -d $tempnode"
    SUBSYSTEM=="usb", ACTION=="add", ATTRS{idVendor}=="03fd", ATTRS{idProduct}=="0013", RUN+="${lib.getExe fxload} -v -t fx2 -i ${ise-fw}/share/xusb_xp2.hex -d $tempnode"
    SUBSYSTEM=="usb", ACTION=="add", ATTRS{idVendor}=="03fd", ATTRS{idProduct}=="0015", RUN+="${lib.getExe fxload} -v -t fx2 -i ${ise-fw}/share/xusb_xse.hex -d $tempnode"

    ACTION=="add", SUBSYSTEMS=="usb", ATTRS{idVendor}=="03fd", MODE="666"

  '';
}
