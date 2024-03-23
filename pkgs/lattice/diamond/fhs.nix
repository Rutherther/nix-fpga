{ pkgs, lib, myLib, requireInstallDir ? false, licenseInterface ? "", ... }:

let
  bypassNetwork = licenseInterface == true || (licenseInterface != "");
  imperativeInterface = licenseInterface == true;
  declarativeInterface = bypassNetwork && !imperativeInterface;
in pkgs.buildFHSEnv {
  multiPkgs = pkgs: with pkgs; [
    coreutils
    fontconfig
    expat
    libgcc
    libjpeg
    libselinux
    gamin
    glib
    stdenv.cc.cc.lib
    zlib
    libpng
    freetype
    tcl-8_5
    alsa-lib
    nss
    nspr
    nsss
    sqlite
    ncurses5
    gmp
    libthai
    pixman
    cups.lib
    avahi
    audit
    libtiff
    dbus.lib
    gnutls
    keyutils.lib
    cairo
    pango
    krb5
    libgcrypt
    libgpg-error
    libtasn1
    gtk2
    jasper
    (perl.withPackages (ps: [
      ps.XMLRegExp
      ps.XMLParser
    ]))

    xorg.libXext
    xorg.libXtst
    xorg.libXft
    xorg.libX11
    xorg.libXrender
    xorg.libXi
    xorg.libXft
    xorg.libXrandr
    xorg.libXfixes
    xorg.libXdamage
    xorg.libXcomposite
    xorg.libXinerama
    xorg.libICE
    xorg.libSM
    libGL
  ];

  name = "diamond";

  multiArch = true;

  unshareNet = bypassNetwork;

  extraBwrapArgs = lib.lists.optionals bypassNetwork [
    "--cap-add CAP_NET_ADMIN"
  ];

  runScript = ''
    ${myLib.runScriptPrefix "diamond" requireInstallDir}
    if [[ ! -z $INSTALL_DIR ]]; then
      export PATH=$INSTALL_DIR/bin/lin64:$PATH
      export LD_LIBRARY_PATH=$INSTALL_DIR/bin/lin64:$LD_LIBRARY_PATH
    fi
    export LD_LIBRARY_PATH=/lib:$LD_LIBRARY_PATH
    '' +

    (lib.optionalString imperativeInterface ''
      if [[ -z $LICENSE_INTERFACE ]]; then
        echo "nix-diamond-error: LICENSE_INTERFACE is not set, but imperative license interface setup has been chosen. Continuing, but expect issues with license."
      else
        ip link add eth0 type dummy
        ip link set dev eth0 address $LICENSE_INTERFACE
      fi
    '') +

    (lib.optionalString declarativeInterface ''
      ip link add eth0 type dummy
      ip link set dev eth0 address ${licenseInterface}
    '') +

    ''
      exec "$@"
    '';

  meta.mainProgram = "diamond";
}
