{ lib, pkgs, ... }:

{
  runScriptPrefix = package: required: ''
    # Search for an imperative declaration of the installation directory of ${package}
    error=0
    if [[ -f ~/.config/${package}/nix.sh ]]; then
      source ~/.config/${package}/nix.sh

    '' +

    lib.optionalString required ''
    else
      echo "nix-${package}-error: Did not find ~/.config/${package}/nix.sh" >&2
      error=1
    fi
    '' +

    lib.optionalString (!required) ''
    else
      echo "nix-${package}-warn: Did not find ~/.config/${package}/nix.sh"
    fi
    '' +

    ''
    if [[ ! -z "$INSTALL_DIR" && ! -d "$INSTALL_DIR" ]]; then
      echo "nix-${package}-error: INSTALL_DIR $INSTALL_DIR isn't a directory" >&2
      error=2
  '' + ''
    fi

    if [[ $error -ne 0 ]]; then
      exit $error
    fi
  '';

  finalPkgGenerator = pkgs.callPackage ./final-pkg-generator.nix {};
}
