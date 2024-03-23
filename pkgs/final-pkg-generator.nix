{ lib, stdenv, customInstallScript ? "", fhsEnv ? "", executables ? "", mainProgram ? "" }:

let
  genScript = file: ''
    #!/usr/bin/env bash
    exec ${lib.getExe fhsEnv} ${file} \"\$@\"
  '';

  createScript = file: ''
   echo "${genScript file}" > $out/bin/${file}
   chmod +x $out/bin/${file}
  '';

  createScripts = map (file: createScript file) executables;

in stdenv.mkDerivation {
  name = mainProgram;

  installPhase = ''
    mkdir -p $out/bin
  '' + customInstallScript + (lib.concatStrings createScripts);

  phases = [ "installPhase" ];

  meta = {
    inherit mainProgram;
  };
}
