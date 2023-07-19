with import <nixpkgs> {};

( let
    pywebio = python311.pkgs.buildPythonPackage rec {
      pname = "pywebio";
      version = "1.8.2";
      format = "setuptools";

      src = fetchPypi {
        inherit pname version;
        hash = "sha256-YXeyCxfegh6lgFFUOMqdvNxDam4esX+cXjV1MfuHqFU=";
      };

      doCheck = false;

      propagatedBuildInputs = [
        pkgs.python311Packages.tornado
        pkgs.python311Packages.user-agents
      ];
    };

  in python311.withPackages (ps: with ps; [
    pywebio
  ])
).env