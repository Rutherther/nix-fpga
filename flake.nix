{
  description = "A very basic flake";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
      runScriptPrefix = package: ''
        # Search for an imperative declaration of the installation directory of ${package}
        if [[ -f ~/.config/${package}/nix.sh ]]; then
          source ~/.config/${package}/nix.sh
        else
          echo "nix-${package}-error: Did not find ~/.config/${package}/nix.sh" >&2
          exit 1
        fi
        if [[ ! -d "$INSTALL_DIR" ]]; then
          echo "nix-${package}-error: INSTALL_DIR $INSTALL_DIR isn't a directory" >&2
          exit 2
      '' + ''
        fi
      '';

      liberoMultiPkgs = pkgs: with pkgs; [
        xlights
        glib
        glibc.dev
        fontconfig
        freetype
        gcc.cc.libgcc
        gcc.cc.libgcc.lib
        xorg.libICE
        xorg.libX11
        xorg.libXau
        libpng
        xorg.libSM
        xorg.libXcursor
        xorg.libXdmcp
        xorg.libXext
        xorg.libXfixes
        xorg.libXinerama
        xorg.libXi
        motif
        xorg.libXmu
        xorg.libXp
        xorg.libXrandr
        xorg.libXrender
        xorg.libXt
        xorg.libXtst
        zlib
        glib
        ksh
        # xorg-x11-fonts-75dpi
        # xorg-x11-fonts-100dpi
        # xorg-x11-fonts-Type1
        libuuid.lib
        libsForQt5.full
        libglvnd
        libxslt
        libxml2
        sqlite
        libkrb5
        systemd
        xorg.libxcb
        xorg.xcbutilimage
        xorg.xcbutilkeysyms
        libxkbcommon
        glibc_multi

        ncurses5
        ncurses
      ];

      motif3-compat = pkgs.stdenv.mkDerivation {
        name = "motif3-compat";
        phases = ["installPhase"];
        installPhase = ''
          mkdir -p $out/lib
          ln -s ${pkgs.motif}/lib/libXm.so.4 $out/lib/libXm.so.3
        '';
      };

      # pkgs for Xilinx tools
      xilinxTargetPkgs = pkgs: with pkgs; [
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
        motif3-compat
        xorg.libXcursor
        xorg.libXft
        xorg.libXmu
        xorg.libXp
        xorg.libXt
        xorg.libXrandr
        xorg.libSM
        xorg.libICE
      ];

    in {
      packages.${system} = {

        libero-shell = pkgs.buildFHSEnv {
          multiPkgs = liberoMultiPkgs;
          targetPkgs = liberoMultiPkgs;

          name = "libero-shell";
          runScript = pkgs.writeScript "libero-shell" ''
            export LD_LIBRARY_PATH=/lib:$LD_LIBRARY_PATH
            exec bash
          '';
        };

        vivado-shell = pkgs.buildFHSEnv {
          targetPkgs = xilinxTargetPkgs;

          name = "vivado-shell";
          runScript = pkgs.writeScript "vivado-shell" ''
            source $INSTALL_DIR/Vivado/2023.1/settings64.sh
            export LD_LIBRARY_PATH=/lib:$LD_LIBRARY_PATH
            exec bash
          '';
        };
        vivado = pkgs.buildFHSEnv {
          targetPkgs = xilinxTargetPkgs;

          name = "vivado-runner";
          runScript = pkgs.writeScript "vivado-runner" ''
            ${runScriptPrefix "vivado"}
            export LD_LIBRARY_PATH=/lib:$LD_LIBRARY_PATH
            exec $INSTALL_DIR/Vivado/2023.1/bin/vivado "$@"
          '';
        };

        ise-shell = pkgs.buildFHSEnv {
          targetPkgs = pkgs: xilinxTargetPkgs pkgs ++ [
            self.packages.${system}.ise-fw
          ];

          name = "ise-shell";
          runScript = pkgs.writeScript "ise-shell" ''
            ${runScriptPrefix "ise"}
            source $INSTALL_DIR/14.7/ISE_DS/settings64.sh $INSTALL_DIR/14.7/ISE_DS
            exec bash
          '';
        };

        ise = pkgs.buildFHSEnv {
          targetPkgs = xilinxTargetPkgs;
          name = "xilinx-runner";

          runScript = ''
            ${runScriptPrefix "ise"}
            source $INSTALL_DIR/14.7/ISE_DS/settings64.sh $INSTALL_DIR/14.7/ISE_DS
            $INSTALL_DIR/14.7/ISE_DS/ISE/bin/lin64/ise
          '';
        };

        ise-fw = pkgs.stdenv.mkDerivation {
          name = "xilinx-jtag-fw";
          phases = ["installPhase"];
          src = ./xilinx/ise/fw;
          installPhase = ''
            mkdir -p $out/share
            cp * $out/share/
          '';
        };

        ise-udev-rules = pkgs.writeTextFile (let
          ise-fw = self.packages.${system}.ise-fw;
        in {
          name = "ise-udev-rules";
          destination = "/etc/udev/rules.d/05-xilinx-ise.rules";
          text = ''
            # version 0003
            SYSFS{idVendor}=="03fd", SYSFS{idProduct}=="0008", MODE="666"
            BUS=="usb", ACTION=="add", SYSFS{idVendor}=="03fd", SYSFS{idProduct}=="0007", RUN+="${pkgs.fxload} -v -t fx2 -I ${ise-fw}/share/xusbdfwu.hex -D $tempnode"
            BUS=="usb", ACTION=="add", SYSFS{idVendor}=="03fd", SYSFS{idProduct}=="0009", RUN+="${pkgs.fxload} -v -t fx2 -I ${ise-fw}/share/xusb_xup.hex -D $tempnode"
            BUS=="usb", ACTION=="add", SYSFS{idVendor}=="03fd", SYSFS{idProduct}=="000d", RUN+="${pkgs.fxload} -v -t fx2 -I ${ise-fw}/share/xusb_emb.hex -D $tempnode"
            BUS=="usb", ACTION=="add", SYSFS{idVendor}=="03fd", SYSFS{idProduct}=="000f", RUN+="${pkgs.fxload} -v -t fx2 -I ${ise-fw}/share/xusb_xlp.hex -D $tempnode"
            BUS=="usb", ACTION=="add", SYSFS{idVendor}=="03fd", SYSFS{idProduct}=="0013", RUN+="${pkgs.fxload} -v -t fx2 -I ${ise-fw}/share/xusb_xp2.hex -D $tempnode"
            BUS=="usb", ACTION=="add", SYSFS{idVendor}=="03fd", SYSFS{idProduct}=="0015", RUN+="${pkgs.fxload} -v -t fx2 -I ${ise-fw}/share/xusb_xse.hex -D $tempnode"
          '';
        });

        vivado-udev-rules = pkgs.writeTextFile {
          name = "vivado-udev-rules";
          destination = "/etc/udev/rules.d/10-xilinx-vivado.rules";
          text = ''
            # xilinx-ftdi-usb.rules
            ACTION=="add", ATTR{idVendor}=="0403", ATTR{manufacturer}=="Xilinx", MODE:="666"

            # xilinx-digilent-usb.rules
            ATTR{idVendor}=="1443", MODE:="666"
            ACTION=="add", ATTR{idVendor}=="0403", ATTR{manufacturer}=="Digilent", MODE:="666"

            # xilinx-pcusb.rules
            ATTR{idVendor}=="03fd", ATTR{idProduct}=="0008", MODE="666"
            ATTR{idVendor}=="03fd", ATTR{idProduct}=="0007", MODE="666"
            ATTR{idVendor}=="03fd", ATTR{idProduct}=="0009", MODE="666"
            ATTR{idVendor}=="03fd", ATTR{idProduct}=="000d", MODE="666"
            ATTR{idVendor}=="03fd", ATTR{idProduct}=="000f", MODE="666"
            ATTR{idVendor}=="03fd", ATTR{idProduct}=="0013", MODE="666"
            ATTR{idVendor}=="03fd", ATTR{idProduct}=="0015", MODE="666"
          '';
        };
      };
    };
}
