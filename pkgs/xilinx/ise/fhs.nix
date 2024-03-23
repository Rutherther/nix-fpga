{ pkgs, myLib, ise-fw, ise-usb-driver, requireInstallDir ? false, ... }:

pkgs.buildFHSEnv {
  targetPkgs = pkgs: ((import ../common.nix).targetPkgs pkgs) ++ [
    pkgs.fxload
    ise-fw
    ise-usb-driver
  ];

  name = "ise";

  runScript = ''
    ${myLib.runScriptPrefix "ise" requireInstallDir}
    if [[ ! -z $INSTALL_DIR ]]; then
      source $INSTALL_DIR/settings64.sh "$INSTALL_DIR"
    fi
    export LD_LIBRARY_PATH=/lib:$LD_LIBRARY_PATH
    export LD_PRELOAD=${ise-usb-driver}/lib/libusb-driver.so
    exec "$@"
  '';

  meta.mainProgram = "ise";
}
