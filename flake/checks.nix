{
  self,
  nixpkgs,
  systems,
}:

{
  checks = nixpkgs.lib.genAttrs systems (
    system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      nixpiLib = import ../lib {
        lib = pkgs.lib;
        inherit pkgs;
      };
    in
    {
      eval-tests = pkgs.callPackage ../tests/eval/eval-test.nix { inherit nixpiLib; };
      invalid-option-tests = pkgs.callPackage ../tests/eval/invalid-option-test.nix { inherit nixpiLib; };
      build-tests = pkgs.callPackage ../tests/build/build-test.nix { inherit nixpiLib; };
      hm-tests = pkgs.callPackage ../tests/integration/hm-test.nix { inherit self system; };
      e2e-tests = pkgs.callPackage ../tests/e2e/e2e-test.nix { inherit nixpiLib; };
      extend-tests = pkgs.callPackage ../tests/build/extend-test.nix { inherit nixpiLib; };
      factory-tests = pkgs.callPackage ../tests/eval/factory-test.nix { inherit nixpiLib; };
      legacy-packages-tests = pkgs.callPackage ../tests/build/legacy-packages-test.nix {
        legacyPackages = self.legacyPackages.${system};
      };
      legal-research-tests = pkgs.callPackage ../tests/legal-research/legal-research-test.nix {
        inherit nixpiLib;
        legalResearchProfile = self.piModules.profiles.legalResearch;
      };
      public-api-tests = pkgs.callPackage ../tests/contract/public-api-test.nix { inherit self; };
      documentation = self.packages.${system}.docs;
    }
    // pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
      nixos-tests = pkgs.callPackage ../tests/integration/nixos-test.nix { inherit self system; };
    }
    // pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
      darwin-tests = pkgs.callPackage ../tests/integration/darwin-test.nix { inherit self system; };
    }
  );
}
