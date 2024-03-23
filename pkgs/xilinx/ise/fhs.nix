{ pkgs, myLib, ise-fw, requireInstallDir ? false, ... }:

pkgs.buildFHSEnv {
  targetPkgs = pkgs: ((import ../common.nix).targetPkgs pkgs) ++ [
    ise-fw
  ];

  name = "ise";

  runScript = ''
    ${myLib.runScriptPrefix "ise" requireInstallDir}
    if [[ ! -z $INSTALL_DIR ]]; then
      source $INSTALL_DIR/settings64.sh "$INSTALL_DIR"
    fi
    export LD_LIBRARY_PATH=/lib:$LD_LIBRARY_PATH
    exec "$@"
  '';

  meta.mainProgram = "ise";
}
