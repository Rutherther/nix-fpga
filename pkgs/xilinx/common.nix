{
  targetPkgs = pkgs: with pkgs; [
    gnumake
    coreutils
    stdenv.cc.cc
    ncurses5
    ncurses
    zlib
    xorg.libX11
    xorg.libXrender
    xorg.libxcb
    xorg.libXext
    xorg.libXtst
    xorg.libXi
    freetype
    gtk2
    glib
    libxcrypt-legacy
    gperftools
    glibc.dev
    fontconfig
    liberation_ttf

    # Xilinx ISE
    glib
    iproute2
    libstdcxx5
    libusb-compat-0_1
    libuuid
    motif
    # motif3-compat
    xorg.libXcursor
    xorg.libXft
    xorg.libXmu
    xorg.libXp
    xorg.libXt
    xorg.libXrandr
    xorg.libSM
    xorg.libICE
  ];
}
