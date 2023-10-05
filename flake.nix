{
  description = "My flake with dream2nix packages";

  inputs = {
    dream2nix.url = "github:nix-community/dream2nix";
    nixpkgs.follows = "dream2nix/nixpkgs";
  };

  outputs =
    { dream2nix
    , nixpkgs
    , self
    , ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # all packages defined inside ./packages/
      packages.${system} = (dream2nix.lib.importPackages {
        projectRoot = ./.;
        # can be changed to ".git" or "flake.nix" to get rid of .project-root
        projectRootFile = "flake.nix";
        packagesDir = ./packages;
        packageSets.nixpkgs = nixpkgs.legacyPackages.${system};
      }) // {
        default = self.packages.${system}.hass;
      };
      devShell.${system} = pkgs.mkShell {
        packages = [
          # required to resolve dependencies
          pkgs.gammu
          pkgs.pkg-config
        ];

        # XXX the pureShellScript wrapper is garbage as it doesn't properly apply nativeBuildInputs
        # this breaks the pypi fetcher
        KEEP_VARS = "PKG_CONFIG_PATH CC CXX AR AS NIX_CFLAGS_COMPILE NIX_LDFLAGS NIX_CFLAGS_LINK NIX_CFLAGS NIX_LDFLAGS";
      };
    };
}
