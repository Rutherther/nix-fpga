{
  description = "A very basic flake";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
      runScriptPrefix = package: required: ''
        # Search for an imperative declaration of the installation directory of ${package}
        error=0
        if [[ -f ~/.config/${package}/nix.sh ]]; then
          source ~/.config/${package}/nix.sh
        else
          echo "nix-${package}-error: Did not find ~/.config/${package}/nix.sh" >&2
          error=1
        fi
        if [[ ! -d "$INSTALL_DIR" ]]; then
          echo "nix-${package}-error: INSTALL_DIR $INSTALL_DIR isn't a directory" >&2
          error=2
      '' + ''
        fi

        if [[ $error -ne 0 ]]; then
          exit $error
        fi
      '';

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

      diamondTargetPkgs = pkgs: with pkgs; [
        fontconfig
        libgcc
        glibc
        stdenv.cc.cc.lib
        xorg.libXext
        xorg.libXft
        xorg.libX11
        xorg.libXrender
      ];

      quartusTargetPkgs = pkgs: with pkgs; [
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
        xorg.libxcb.out
        xorg.xcbutilrenderutil.out
        xorg.libXau
        xorg.libXdmcp
        gtk2
        libelf
        expat
        dbus.lib
        brotli.lib
        libpng
        bzip2.out
      ];

      questaFhsEnv = pkgs.buildFHSEnv {
        targetPkgs = quartusTargetPkgs;
        name = "questasim-env";
        runScript = pkgs.writeScript "questasim-env" ''
          ${runScriptPrefix "questa" true}
          if [[ ! -z $INSTALL_DIR ]]; then
            export PATH=$INSTALL_DIR/bin:$PATH
          fi
          export LD_LIBRARY_PATH=/lib:$LD_LIBRARY_PATH
          exec "$@"
        '';
      };

      questaFiles = [
        "crd2bin" "dumplog64" "flps_util" "hdloffice" "hm_entity" "jobspy" "mc2com"
        "mc2perfanalyze" "mc2_util" "qhcvt" "qhdel" "qhdir" "qhgencomp" "qhlib" "qhmake" "qhmap"
        "qhsim" "qrun" "qverilog" "qvhcom" "qvlcom" "qwave2vcd" "qwaveman" "qwaveutils"
        "sccom" "scgenmod" "sdfcom" "sm_entity" "triage" "vcd2qwave" "vcd2wlf" "vcom" "vcover"
        "vdbg" "vdel" "vdir" "vencrypt" "verror" "vgencomp" "vhencrypt" "vis" "visualizer"
        "vlib" "vlog" "vmake" "vmap" "vopt" "vovl" "vrun"
        "vsim" "wlf2log" "wlf2vcd" "wlfman" "wlfrecover" "xml2ucdb"
      ];

      wrappedQuestaScripts = map (x: pkgs.writeScriptBin x ''
        exec ${questaFhsEnv}/bin/questasim-env ${x} "$@"
      '') questaFiles;

    in {
      packages.${system} = {
        diamond-shell = pkgs.buildFHSEnv {
          multiPkgs = diamondTargetPkgs;
          name = "diamond-shell";
          multiArch = true;
          runScript = pkgs.writeScript "diamond-shell" ''
            export LD_LIBRARY_PATH=/lib:$LD_LIBRARY_PATH
            exec bash
          '';
        };
        quartus-shell = pkgs.buildFHSEnv {
          targetPkgs = quartusTargetPkgs;
          name = "quartus-shell";
          runScript = pkgs.writeScript "quartus-shell" ''
            ${runScriptPrefix "quartus" false}
            if [[ ! -z $INSTALL_DIR ]]; then
              export PATH=$INSTALL_DIR/quartus/bin:$INSTALL_DIR/questa_fse/bin:$PATH
            fi
            export LD_LIBRARY_PATH=/lib:$LD_LIBRARY_PATH
            exec bash
          '';
        };

        quartus = pkgs.buildFHSEnv {
          targetPkgs = quartusTargetPkgs;
          name = "quartus";
          runScript = pkgs.writeScript "quartus" ''
            ${runScriptPrefix "quartus" true}
            export LD_LIBRARY_PATH=/lib:$LD_LIBRARY_PATH
            exec $INSTALL_DIR/quartus/bin/quartus
          '';
        };

        questa = pkgs.buildEnv {
          name = "questa";
          paths = wrappedQuestaScripts ++ [
            (pkgs.writeTextFile {
              name = "modelsim.ini";
              text = ''
                Dummy ini
                # For VUnit to find ModelSim.
              '';
              destination = "/modelsim.ini";
            })
          ];

          meta = {
            description = "Environment containing QuestaSim/ModelSim executable files.";
            mainProgram = "vsim";
          };
        };

        quartus-udev-rules = pkgs.writeTextFile {
          name = "quartus-usbblaster";
          destination = "/etc/udev/rules.d/51-usbblaster.rules";
          text = ''
            # Intel FPGA Download Cable
            SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6001", MODE="0666"
            SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6002", MODE="0666"
            SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6003", MODE="0666"

            # Intel FPGA Download Cable II
            SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6010", MODE="0666"
            SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6810", MODE="0666"
          '';
        };

        vivado-shell = pkgs.buildFHSEnv {
          targetPkgs = xilinxTargetPkgs;

          name = "vivado-shell";
          runScript = pkgs.writeScript "vivado-shell" ''
            ${runScriptPrefix "ise" false}
            if [[ ! -z $INSTALL_DIR ]]; then
              source $INSTALL_DIR/Vivado/2023.1/settings64.sh
            fi
            export LD_LIBRARY_PATH=/lib:$LD_LIBRARY_PATH
            exec bash
          '';
        };
        vivado = pkgs.buildFHSEnv {
          targetPkgs = xilinxTargetPkgs;

          name = "vivado-runner";
          runScript = pkgs.writeScript "vivado-runner" ''
            ${runScriptPrefix "vivado" true}
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
            ${runScriptPrefix "ise" false}
            if [[ ! -z $INSTALL_DIR ]]; then
              source $INSTALL_DIR/14.7/ISE_DS/settings64.sh $INSTALL_DIR/14.7/ISE_DS
            fi
            exec bash
          '';
        };

        ise = pkgs.buildFHSEnv {
          targetPkgs = xilinxTargetPkgs;
          name = "xilinx-runner";

          runScript = ''
            ${runScriptPrefix "ise" true}
            source $INSTALL_DIR/14.7/ISE_DS/settings64.sh $INSTALL_DIR/14.7/ISE_DS
            $INSTALL_DIR/14.7/ISE_DS/ISE/bin/lin64/ise
          '';
        };

        ise-fw = pkgs.stdenv.mkDerivation {
          name = "xilinx-jtag-fw";
          phases = ["unpackPhase" "installPhase"];
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
