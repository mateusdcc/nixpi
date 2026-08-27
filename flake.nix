{
  description = "Nix-native declarative configuration framework for the Pi coding agent";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    deep-comprehension-engine = {
      url = "github:mateusdcc/deep-comprehension-engine";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      deep-comprehension-engine,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      nixpiLib = nixpkgs.lib.makeExtensible (
        _:
        import ./lib {
          lib = nixpkgs.lib;
        }
      );
      overlay = final: _: {
        nixpi = self.packages.${final.stdenv.hostPlatform.system};
      };
      lib = nixpiLib // {
        nixpi = nixpiLib;
        inherit overlay;
      };
      deprecated =
        old: replacement:
        nixpiLib.deprecation.warn {
          inherit old replacement;
        };
    in
    {
      inherit lib;
      overlays.default = overlay;
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    }
    // import ./flake/modules.nix {
      inherit self deprecated;
      deepComprehensionEngine = deep-comprehension-engine;
    }
    // import ./flake/templates.nix
    // import ./flake/packages.nix {
      inherit
        self
        nixpkgs
        systems
        deprecated
        ;
      deepComprehensionEngine = deep-comprehension-engine;
    }
    // import ./flake/checks.nix { inherit self nixpkgs systems; }
    // import ./flake/legacy-packages.nix { inherit nixpkgs systems; };
}
