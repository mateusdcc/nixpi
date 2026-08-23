{
  description = "Nix-native declarative configuration framework for the Pi coding agent";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      lib = import ./lib {
        lib = nixpkgs.lib;
      };
    in
    {
      inherit lib;

      piModules = {
        default = import ./modules;
        core = import ./modules/core/package.nix;
        profiles = {
          minimal = import ./modules/profiles/minimal.nix;
          research = import ./modules/profiles/research.nix;
        };
        extensions = {
          echo = import ./modules/extensions/echo.nix;
          ripgrep-search = import ./modules/extensions/ripgrep-search.nix;
          plan-mode = import ./modules/extensions/plan-mode.nix;
          pi-gpt-search = import ./modules/extensions/pi-gpt-search.nix;
          obsidian = import ./modules/extensions/obsidian.nix;
        };
        skills = {
          commit-style = import ./modules/skills/commit-style.nix;
        };
        providers = {
          antigravity = import ./modules/providers/antigravity.nix;
        };
      };

      homeManagerModules = {
        default = import ./integrations/home-manager.nix;
        pi = import ./integrations/home-manager.nix;
      };

      templates = {
        standalone = {
          path = ./templates/standalone;
          description = "Standalone configured Pi environment";
        };
        home-manager = {
          path = ./templates/home-manager;
          description = "Home Manager configuration for Pi";
        };
        devshell = {
          path = ./templates/devshell;
          description = "Project-specific development shell with Pi";
        };
      };

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          nixpiLib = import ./lib {
            lib = pkgs.lib;
            inherit pkgs;
          };
          mkExt = nixpiLib.mkPiExtension;
          antigravityPkg = pkgs.callPackage ./packages/providers/antigravity {
            mkPiExtension = mkExt;
          };
        in
        {
          default = nixpiLib.makePi {
            inherit pkgs;
            modules = [
              (
                { config, ... }:
                {
                  programs.pi = {
                    enable = true;
                    providers.antigravity.enable = true;
                    settings = {
                      defaultProvider = config.programs.pi.providers.antigravity;
                      defaultModel = config.programs.pi.providers.antigravity.models."gemini-3.7-flash";
                      theme = "dark";
                    };
                    extensions = {
                      echo.enable = true;
                      ripgrep-search.enable = true;
                    };
                    skills = {
                      commit-style.enable = true;
                    };
                  };
                }
              )
            ];
          };

          pi-unwrapped = pkgs.pi-coding-agent;
          echo = pkgs.callPackage ./packages/extensions/echo { mkPiExtension = mkExt; };
          ripgrep-search = pkgs.callPackage ./packages/extensions/ripgrep-search {
            mkPiExtension = mkExt;
          };
          plan-mode = pkgs.callPackage ./packages/extensions/plan-mode { mkPiExtension = mkExt; };
          pi-gpt-search = pkgs.callPackage ./packages/extensions/pi-gpt-search {
            mkPiExtension = mkExt;
          };
          obsidian = pkgs.callPackage ./packages/extensions/obsidian {
            mkPiExtension = mkExt;
          };
          antigravity = antigravityPkg;
          pi-antigravity = antigravityPkg;
          commit-style = pkgs.callPackage ./packages/skills/commit-style {
            mkPiSkill = nixpiLib.mkPiSkill;
          };
          skill-commit-style = pkgs.callPackage ./packages/skills/commit-style {
            mkPiSkill = nixpiLib.mkPiSkill;
          };
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          configuredPi = self.packages.${system}.default;
        in
        {
          default = pkgs.mkShell {
            packages = [
              configuredPi
              pkgs.nixfmt
              pkgs.git
              pkgs.ripgrep
            ];
          };
        }
      );

      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          nixpiLib = import ./lib {
            lib = pkgs.lib;
            inherit pkgs;
          };
        in
        {
          eval-tests = pkgs.callPackage ./tests/eval/eval-test.nix {
            inherit nixpiLib;
          };
          invalid-option-tests = pkgs.callPackage ./tests/eval/invalid-option-test.nix {
            inherit nixpiLib;
          };
          build-tests = pkgs.callPackage ./tests/build/build-test.nix {
            inherit nixpiLib;
          };
          hm-tests = pkgs.callPackage ./tests/integration/hm-test.nix { };
          e2e-tests = pkgs.callPackage ./tests/e2e/e2e-test.nix {
            inherit nixpiLib;
          };
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
