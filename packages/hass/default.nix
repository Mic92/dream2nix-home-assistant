{ config
, dream2nix
, lib
, ...
}:
let
  version = "2023.10.0";

  src = config.deps.python3.pkgs.fetchPypi {
    pname = "homeassistant";
    inherit version;
    hash = "sha256-UmgIQJRQRDMzjUO9lJVpKsIvrFHBzoXc5Kig69ZHttU=";
  };
in
{
  imports = [
    dream2nix.modules.dream2nix.pip
  ];

  deps = { nixpkgs, ... }: {
    python = nixpkgs.python311;
    cc = nixpkgs.stdenv.cc;
    gammu = nixpkgs.gammu;
    openblas = nixpkgs.openblas;
    autoconf = nixpkgs.autoconf;
    runCommand = nixpkgs.runCommand;
    rsync = nixpkgs.rsync;
    buildEnv = nixpkgs.buildEnv;
  };

  name = "homeassistant";
  inherit version;
  buildPythonPackage.catchConflicts = false;
  buildPythonPackage.format = "pyproject";

  mkDerivation = {
    inherit src;
    nativeBuildInputs = [
      config.deps.python.pkgs.setuptools
      config.deps.python.pkgs.wheel
    ];
    propagatedBuildInputs = [
      # these are soo many dependencies that our stack overflows because of environment variables
      (config.deps.buildEnv {
        name = "env";
        paths = builtins.map (drv: drv.public) (builtins.attrValues (lib.filterAttrs (n: v: n != "homeassistant") config.pip.drvs));
        ignoreCollisions = true;
      })

    ];
    postPatch = ''
      sed -i 's/wheel[~=]/wheel>/' pyproject.toml
      sed -i 's/setuptools[~=]/setuptools>/' pyproject.toml
    '';
  };

  pip = {
    pipFlags = [
      "-c"
      "${./package_constraints.txt}"
    ];
    #pypiSnapshotDate = "2023-10-05";
    requirementsList = [
      "homeassistant==${version}"
    ];
    requirementsFiles = [ "${./requirements.txt}" ];
    # XXX those nativeBuildInputs are not yet correctly forwarded
    nativeBuildInputs = [
      config.deps.gammu
      config.deps.cc
      config.deps.openblas
    ];
    drvs = {
      apcaccess.mkDerivation = {
        buildInputs = [ 
          config.deps.python.pkgs.pytest-runner
        ];
      };
      dtlssocket.mkDerivation = {
        nativeBuildInputs = [ 
          config.deps.python.pkgs.cython
          config.deps.autoconf
        ];
      };
      ms-cv.mkDerivation = {
        buildInputs = [ 
          config.deps.python.pkgs.pytest-runner
        ];
      };
      pygatt.mkDerivation = {
        buildInputs = [ 
          config.deps.python.pkgs.nose 
        ];
        nativeBuildInputs = [ 
          config.deps.python.pkgs.wheel 
        ];
      };
    };
  };
}
