{pkgs, lib, myLib, requireInstallDir ? false }:

pkgs.buildFHSEnv {
  targetPkgs =
  pkgs: with pkgs; [
    stdenv.cc.cc.lib
    zlib
    glib
    libxcrypt-legacy
    libpng12
    freetype
    fontconfig.lib
    xorg.libSM
    xorg.libICE
    xorg.libXrender
    xorg.libXext
    xorg.libX11
    xorg.libXtst
    xorg.libXi
    xorg.libXft
    xorg.xcbutil
    xorg.libxcb.out
    xorg.xcbutilrenderutil.out
    xorg.libXau
    xorg.libXdmcp
    qt6.qtwayland
    libsForQt5.qt5.qtwayland
    gtk2
    libelf
    expat
    dbus.lib
    brotli.lib
    libpng
    bzip2.out
  ];

  name = "quartus";

  runScript = pkgs.writeScript "questasim-env" ''
    #!/usr/bin/env bash
    ${myLib.runScriptPrefix "quartus" requireInstallDir}
    if [[ ! -z $INSTALL_DIR ]]; then
      export PATH=$INSTALL_DIR/quartus/bin:$PATH
    fi
    export LD_LIBRARY_PATH=/lib:$LD_LIBRARY_PATH
    exec "$@"
  '';

  meta.mainProgram = "quartus";
}
