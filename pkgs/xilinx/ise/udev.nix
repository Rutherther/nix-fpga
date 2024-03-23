{ pkgs, fxload, ise-fw, ... }:

pkgs.writeTextFile {
  name = "ise-udev-rules";
  destination = "/etc/udev/rules.d/05-xilinx-ise.rules";
  text = ''
    # version 0003
    ATTRS{idVendor}=="03fd", ATTRS{idProduct}=="0008", MODE="666"
    SUBSYSTEM=="usb", ACTION=="add", ATTRS{idVendor}=="03fd", ATTRS{idProduct}=="0007", RUN+="${fxload} -v -t fx2 -I ${ise-fw}/share/xusbdfwu.hex -D $tempnode"
    SUBSYSTEM=="usb", ACTION=="add", ATTRS{idVendor}=="03fd", ATTRS{idProduct}=="0009", RUN+="${fxload} -v -t fx2 -I ${ise-fw}/share/xusb_xup.hex -D $tempnode"
    SUBSYSTEM=="usb", ACTION=="add", ATTRS{idVendor}=="03fd", ATTRS{idProduct}=="000d", RUN+="${fxload} -v -t fx2 -I ${ise-fw}/share/xusb_emb.hex -D $tempnode"
    SUBSYSTEM=="usb", ACTION=="add", ATTRS{idVendor}=="03fd", ATTRS{idProduct}=="000f", RUN+="${fxload} -v -t fx2 -I ${ise-fw}/share/xusb_xlp.hex -D $tempnode"
    SUBSYSTEM=="usb", ACTION=="add", ATTRS{idVendor}=="03fd", ATTRS{idProduct}=="0013", RUN+="${fxload} -v -t fx2 -I ${ise-fw}/share/xusb_xp2.hex -D $tempnode"
    SUBSYSTEM=="usb", ACTION=="add", ATTRS{idVendor}=="03fd", ATTRS{idProduct}=="0015", RUN+="${fxload} -v -t fx2 -I ${ise-fw}/share/xusb_xse.hex -D $tempnode"

    ACTION=="add", SUBSYSTEMS=="usb", ATTRS{idVendor}=="03fd", MODE="666"

  '';
}
