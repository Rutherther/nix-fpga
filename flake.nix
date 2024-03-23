{
  description = "A very basic flake";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };

      myLib = import ./pkgs/common.nix { inherit pkgs; inherit (pkgs) lib; };

    in {
      packages.${system} = {

        questa-shell = pkgs.callPackage ./pkgs/questa/fhs-shell.nix { inherit myLib; };
        questa = pkgs.callPackage ./pkgs/questa/fhs-package.nix { inherit myLib; };

        quartus-shell = pkgs.callPackage ./pkgs/intel/quartus/fhs-shell.nix { inherit myLib; };
        quartus = pkgs.callPackage ./pkgs/intel/quartus/fhs-package.nix { inherit myLib; };
        quartus-udev-rules = pkgs.callPackage ./pkgs/intel/quartus/udev.nix {};

        vivado-shell = pkgs.callPackage ./pkgs/xilinx/vivado/fhs-shell.nix { inherit myLib; };
        vivado = pkgs.callPackage ./pkgs/xilinx/vivado/fhs-package.nix { inherit myLib; };
        vivado-udev-rules = pkgs.callPackage ./pkgs/xilinx/vivado/udev.nix {};

        ise-shell = pkgs.callPackage ./pkgs/xilinx/ise/fhs-shell.nix {
          inherit myLib;
          ise-usb-driver = self.packages.${system}.ise-usb-driver;
        };
        ise = pkgs.callPackage ./pkgs/xilinx/ise/fhs-package.nix {
          inherit myLib;
          ise-usb-driver = self.packages.${system}.ise-usb-driver;
        };
        ise-udev-rules = pkgs.callPackage ./pkgs/xilinx/ise/udev.nix {
          inherit myLib;
          ise-fw = self.packages.${system}.ise-fw;
        };
        ise-fw = pkgs.callPackage ./pkgs/xilinx/ise/fw.nix { inherit myLib; };
        ise-usb-driver = pkgs.callPackage ./pkgs/xilinx/ise/usb-driver.nix {};
      };
    };
}
