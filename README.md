# FPGA, ASIC tools on Nix

This repository is inspired by how [nix-matlab](https://gitlab.com/doronbehar/nix-matlab) works.
Most packages here are not kept in the Nix store. They are instead installed somewhere else,
and the packages here are capable of calling the target executables in FHS environment.

## Available packages
Currently supporting: ISE, Vivado, Quartus, Questa.
- ISE
- Vivado
- Quartus
- QuestaSim / ModelSim

## Installing software
To install any of the available software, you will first want to run the installer
of the software in its fhs shell environment. These are called `{sw}-shell`.
For example, to install Quartus, you would do
``` sh
nix run github:Rutherther/nix-fpga#quartus-shell
```
Then go about the installation manually and install wherever.

After the installation, it's important to configure where is Quartus installed. The
FHS scripts are sourcing `~/.config/quartus/nix.sh` file, and assuming `INSTALL_DIR` is
the location of the installation. Specify the whole path including the folder with version
of the software, ie.
``` sh
INSTALL_DIR=/opt/IntelFPGA/quartus/23.1std_lite
```

## Running software
You can either run the software manually from the shell, or run the
package version that starts the main program of the toolchain.

Ie. to run quartus, you would do `nix run github:Rutherther/nix-fpga#quartus`.
To run the shell, you would follow what was done for the installation,
`nix run github:Rutherther/nix-fpga#quartus-shell`. All vendor scripts will be
sourced, bins added to `$PATH`, so the software may be ran directly.

The main package also usually has more executables inside of its binary folder,
these are all wrapper scripts that call the FHS environment. If you want to use these,
you would typically add the package to your path in your shell and that will add
all executables to your `$PATH`.

## Udev rules
If you want to flash the FPGA, you will need udev rules installed.
These cannot be installed the same way as on other Linux systems via
vendor's installation scripts. Instead, udev rules are copied to this repository,
and made available via `{sw}-udev-rules`. For example `quartus-udev-rules`.
These have to be put into `services.udev.packages` of your NixOS configuration
to make connection with board possible.

## Licensing
To provide the correct license to the software,
I suggest using the configuration script. This script is
sourced, so you can just put in `export LM_LICENSE_FILE` line
that will set path to the license

## Software specifics
How the configuration should look like, what
options can be used etc.

### Quartus
I was not able to test the udev rules for quartus as I do not have
Intel board on hand.

``` sh
> cat ~/.config/quartus/nix.sh
INSTALL_DIR=/opt/IntelFPGA/quartus/23.1std_lite
```


### Questa
The Questa package allows to add dummy network interface. This allows
license for any interface to work fine. It also bypasses the network
check that has to be performed normally. To enable this bypass, override
the package like so:

``` nix
quartus.override {
    licenseInterface = "AA:BB:CC:DD:EE:FF"; # put interface from the license instead.
};
```

Alternatively you can set this `licenseInterface` to `true`, and configure via `$LICENSE_INTERFACE`
variable declared inside of the `nix.sh` configuration file.

This will also mean internet cannot be used inside of Questa, but to my knowledge
it doesn't use internet in normal usage at all.

``` sh
> cat ~/.config/questa/nix.sh
INSTALL_DIR=/opt/IntelFPGA/quartus/23.1std_lite/questa_fse
LICENSE_INTERFACE=AA:BB:CC:DD:EE:FF # Do not forget to override with `licenseInterface = true;`
export LM_LICENSE_FILE=/path/to/my/license.dat
```

### ISE
I was not able to get the Platform Cable working with ISE. I ended up
going into Vivado, where it seems even older models can be flashed.
So I do synthesis, routing, bitfile generation in ISE, and then flash
via Vivado.

``` sh
> cat ~/.config/ise/nix.sh
INSTALL_DIR=/opt/Xilinx/ISE/14.7/ISE_DS
```

### Vivado

``` sh
> cat ~/.config/vivado/nix.sh
INSTALL_DIR=/opt/Xilinx/Vivado/2023.1
```
