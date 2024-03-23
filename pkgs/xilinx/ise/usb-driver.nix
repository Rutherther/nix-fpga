{ fetchgit, multiStdenv, stdenv, libusb, libftdi, ... }:

multiStdenv.mkDerivation {
  name = "ise-usb-driver";

  buildInputs = [
    libusb
    libftdi
  ];

  installPhase = ''
    mkdir -p $out/lib
    mv libusb-driver.so $out/lib/
  '';

  src = fetchgit {
    url = "git://git.zerfleddert.de/usb-driver";
    rev = "2d19c7cb325c8cd15b252dd5b8de7a643bb5295d";
    hash = "sha256-VQEnIuaEW1Kg0O9AYKs8hJKrNTVnOpzVIaFVDjn1Bpg=";
  };
}
