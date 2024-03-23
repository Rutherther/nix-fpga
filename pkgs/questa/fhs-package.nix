{ pkgs, myLib, licenseInterface ? "" }:

myLib.finalPkgGenerator.override {
  mainProgram = "vsim";

  fhsEnv = pkgs.callPackage ./fhs.nix { inherit myLib licenseInterface; requireInstallDir = true; };

  executables = [
    "crd2bin" "dumplog64" "flps_util" "hdloffice" "hm_entity" "jobspy" "mc2com"
    "mc2perfanalyze" "mc2_util" "qhcvt" "qhdel" "qhdir" "qhgencomp" "qhlib" "qhmake" "qhmap"
    "qhsim" "qrun" "qverilog" "qvhcom" "qvlcom" "qwave2vcd" "qwaveman" "qwaveutils"
    "sccom" "scgenmod" "sdfcom" "sm_entity" "triage" "vcd2qwave" "vcd2wlf" "vcom" "vcover"
    "vdbg" "vdel" "vdir" "vencrypt" "verror" "vgencomp" "vhencrypt" "vis" "visualizer"
    "vlib" "vlog" "vmake" "vmap" "vopt" "vovl" "vrun"
    "vsim" "wlf2log" "wlf2vcd" "wlfman" "wlfrecover" "xml2ucdb"
  ];

  # This is here for compatibility with some tools like
  # VUnit, where modelsim.ini is checked to see if the
  # given path is ModelSim installation.
  customInstallScript = ''
    echo -e " \
    ; This is here for compatibility with some tools like\n \
    ; VUnit, where modelsim.ini is checked in modelsim/bin/.. to see if the\n \
    ; given path is ModelSim installation. \
    " > "$out/modelsim.ini"
  '';
}
