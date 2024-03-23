{pkgs, lib, myLib, requireInstallDir ? false, licenseInterface ? "" }:

let
  bypassNetwork = licenseInterface == true || (licenseInterface != "");
  imperativeInterface = licenseInterface == true;
  declarativeInterface = bypassNetwork && !imperativeInterface;
in pkgs.buildFHSEnv {
  targetPkgs =
  pkgs: with pkgs; [
    stdenv.cc.cc.lib
    ncurses.lib
    libuuid
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

  name = "questasim";

  unshareNet = bypassNetwork;

  extraBwrapArgs = lib.lists.optionals bypassNetwork [
    "--cap-add CAP_NET_ADMIN"
  ];

  runScript = ''
    #!/usr/bin/env bash
    ${myLib.runScriptPrefix "questa" requireInstallDir}
    if [[ ! -z $INSTALL_DIR ]]; then
      export PATH=$INSTALL_DIR/bin:$PATH
    fi
    export LD_LIBRARY_PATH=/lib:$LD_LIBRARY_PATH
    '' +

    (lib.optionalString imperativeInterface ''
      if [[ -z $LICENSE_INTERFACE ]]; then
        echo "nix-questa-error: LICENSE_INTERFACE is not set, but imperative license interface setup has been chosen. Continuing, but expect issues with license."
      else
        ip link add eth0 type dummy
        ip link set dev eth0 address $LICENSE_INTERFACE
      fi
    '') +

    (lib.optionalString declarativeInterface ''
      ip link add eth0 type dummy
      ip link set dev eth0 address ${licenseInterface}
    # # # '') +

    ''
      exec "$@"
    '';

  meta.mainProgram = "questasim";
}
