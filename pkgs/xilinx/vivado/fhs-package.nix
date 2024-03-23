{ pkgs, myLib }:

myLib.finalPkgGenerator.override {
  mainProgram = "vivado";

  fhsEnv = pkgs.callPackage ./fhs.nix { inherit myLib; requireInstallDir = true; };

  executables = [
    # From Vivado bin folder
    "bootgen"
    "cdoutil"
    "cdoutil_int"
    "combine_dfx_bitstreams"
    "cs_server"
    "diffbd"
    "hw_server"
    "hw_serverpv"
    "ldlibpath.sh"
    "loader"
    "manage_ipcache"
    "program_ftdi"
    "rdiArgs.sh"
    "setEnvAndRunCmd.sh"
    "setupEnv.sh"
    "stapl_player"
    "svf_utility"
    "symbol_server"
    "tcflog"
    "unsetldlibpath.sh"
    "unwrapped"
    "updatemem"
    "vivado"
    "vlm"
    "wbtcv"
    "xar"
    "xcd"
    "xcrg"
    "xelab"
    "xlicdiag"
    "xrcserver"
    "xrt_server"
    "xsc"
    "xsdb"
    "xsim"
    "xtclsh"
    "xvc_pcie"
    "xvhdl"
    "xvlog"

    # From Vitis bin folder
    "apcc"
    "hlsArgs.sh"
    "ldlibpath.sh"
    "loader"
    "rdiArgs.sh"
    "setEnvAndRunCmd.sh"
    "setupEnv.sh"
    "unsetldlibpath.sh"
    "unwrapped"
    "vitis_hls"
    "xlicdiag"

    # From ModelComposer bin folder
    "ldlibpath.sh"
    "loader"
    "model_composer"
    "modelcomposerArgs.sh"
    "rdiArgs.sh"
    "setEnvAndRunCmd.sh"
    "setPatchEnv.sh"
    "setupEnv.sh"
    "unsetldlibpath.sh"
    "unwrapped"

    # From DocNav bin folder
    "AppRun"
    "docnav"
    "lib"
    "libexec"
    "pdfjs"
    "plugins"
    "translations"
  ];
}
