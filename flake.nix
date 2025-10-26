{
  description = "Development environment for sblg";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    # This line replaces all the `forAllSystems` boilerplate
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Get pkgs for the current system
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        # --- 1. Development Shell ---
        # Run `nix develop`
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.stdenv.cc   # C compiler (gcc)
            pkgs.gnumake     # make
            pkgs.pkg-config  # pkg-config
            pkgs.expat       # The required lib
          ];
        };

        # --- 2. Package Build ---
        # Run `nix build`
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "sblg";
          version = "1.0.0"; # <-- Remember to update this from version.h
          src = ./.;

          nativeBuildInputs = [
            pkgs.gnumake
            pkgs.pkg-config
          ];

          buildInputs = [
            pkgs.expat
          ];
          configurePhase = ''
          runHook preConfigure
          ./configure PREFIX=$out
          runHook postConfigure
          '';
        };

        # --- 3. Default App ---
        # Run `nix run`
        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/sblg";
        };
      }
    );
}
