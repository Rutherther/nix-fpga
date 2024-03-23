{ pkgs, myLib, ise-fw, ... }:

pkgs.buildFHSEnv {
  targetPkgs = pkgs: ((import ../common.nix).targetPkgs pkgs) ++ [
    ise-fw
  ];

  name = "ise";

  runScript = ''
    ${myLib.runScriptPrefix "ise" false}
    if [[ ! -z $INSTALL_DIR ]]; then
      source $INSTALL_DIR/settings64.sh "$INSTALL_DIR"
    fi
    export LD_LIBRARY_PATH=/lib:$LD_LIBRARY_PATH
    exec "$@"
  '';

  meta.mainProgram = "ise";
}
