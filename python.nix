with import <nixpkgs> {};

( let
    pywebio = python311.pkgs.buildPythonPackage rec {
      pname = "pywebio";
      version = "1.8.2";
      format = "setuptools";

      src = fetchPypi {
        inherit pname version;
        hash = "sha256-Io06fbhszK0iIqFxxoADhojWysLhDRxHFeO3Z/cnJuo=";
      };
    };

  in python311.withPackages (ps: with ps; [
    requests
    pywebio
  ])
).env