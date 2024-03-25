{ pkgs, myLib, licenseInterface ? "" }:

myLib.finalPkgGenerator.override {
  mainProgram = "diamond";

  fhsEnv = pkgs.callPackage ./fhs.nix { inherit myLib licenseInterface; requireInstallDir = true; };

  executables = [
    "cableserver"
    "cableservermain"
    "check_systemlibrary_diamond.bash"
    "check_systemlibrary_diamond.csh"
    "createdevfile"
    "dbgmain"
    "ddtcmain"
    "ddtcmd"
    "ddtmain"
    "debugger"
    "deployment"
    "diamond"
    "diamondc"
    "diamond_env"
    "engines"
    "expwrap"
    "fileutility"
    "fpgac"
    "fpgae"
    "hdl2jhd"
    "hdlparser"
    "htmlrpt"
    "ipexpress"
    "ipxwrapper"
    "istflow"
    "launchmicosystem"
    "licensedebug"
    "mdlmain"
    "mergejedec"
    "messagesupport"
    "mgnmain"
    "model300"
    "moduleparser"
    "mpartrce"
    "naf2sym"
    "opwebhlp"
    "pfumain"
    "pgrcmain"
    "pgrcmd"
    "pgrmain"
    "pnmain"
    "pnmainc"
    "powercal"
    "programmer"
    "psbasccfgwrap"
    "psbascwrap"
    "psbrtlwrap"
    "pwcmain"
    "pwcwrap"
    "revealrva"
    "rvamain"
    "sbpgen"
    "sbpmain"
    "sch2sym"
    "sch2vhd"
    "sch2vlog"
    "schexe"
    "sedwrap"
    "setupenv"
    "shvmain"
    "symexe"
    "syndevgen"
    "synpwrap"
    "TCP2CABLE"
    "tmcheck"
    "toolapps"
    "update"
    "updwrapper"
    "wetmain"
  ];
}
