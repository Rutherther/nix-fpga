{ pkgs, myLib, requireInstallDir ? false, ... }:

pkgs.buildFHSEnv {
  targetPkgs = (import ../common.nix).targetPkgs;

  name = "vivado";

  runScript = ''
    ${myLib.runScriptPrefix "vivado" requireInstallDir}
    if [[ ! -z $INSTALL_DIR ]]; then
      source $INSTALL_DIR/settings64.sh $INSTALL_DIR
    fi
    export LD_LIBRARY_PATH=/lib:$LD_LIBRARY_PATH
    exec "$@"
  '';

  meta.mainProgram = "vivado";
}
