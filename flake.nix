{
  description = "Nix-native declarative configuration framework for the Pi coding agent";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    deep-comprehension-engine.url = "path:/Users/mateusdcc/Projects/deep-comprehension-engine";
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
          learning = deep-comprehension-engine.piModules.default;
          legalResearch = import ./modules/profiles/legal-research.nix;
        };
        extensions = {
          echo = import ./modules/extensions/echo.nix;
          ripgrep-search = import ./modules/extensions/ripgrep-search.nix;
          plan-mode = import ./modules/extensions/plan-mode.nix;
          pi-gpt-search = import ./modules/extensions/pi-gpt-search.nix;
          obsidian = deep-comprehension-engine.piModules.extensions.obsidian;
          researchTools = import ./modules/extensions/research-tools.nix;
        };
        skills = {
          commit-style = import ./modules/skills/commit-style.nix;
          legalPainDiscovery = import ./modules/skills/legal-pain-discovery.nix;
          voiceOfCustomerMining = import ./modules/skills/voice-of-customer-mining.nix;
          evidenceDeduplication = import ./modules/skills/evidence-deduplication.nix;
          legalMarketSegmentation = import ./modules/skills/legal-market-segmentation.nix;
          competitorGapAnalysis = import ./modules/skills/competitor-gap-analysis.nix;
          brazilLocalizationTest = import ./modules/skills/brazil-localization-test.nix;
          opportunityScoring = import ./modules/skills/opportunity-scoring.nix;
          productOpportunityReport = import ./modules/skills/product-opportunity-report.nix;
          obsidianScreenshot = deep-comprehension-engine.piModules.skills.obsidianScreenshot;
          socraticTutor = deep-comprehension-engine.piModules.skills.socraticTutor;
          feynmanTechnique = deep-comprehension-engine.piModules.skills.feynmanTechnique;
          activeRecallNotes = deep-comprehension-engine.piModules.skills.activeRecallNotes;
          literatureDeepDive = deep-comprehension-engine.piModules.skills.literatureDeepDive;
          deepComprehensionEngine = deep-comprehension-engine.piModules.skills.deepComprehensionEngine;
          giftedDiagnosticProbe = deep-comprehension-engine.piModules.skills.giftedDiagnosticProbe;
          paginatedAtomicNotes = deep-comprehension-engine.piModules.skills.paginatedAtomicNotes;
          mermaidDiagrams = deep-comprehension-engine.piModules.skills.mermaidDiagrams;
        };
        providers = {
          antigravity = import ./modules/providers/antigravity.nix;
        };
      };

      nixosModules = {
        default = import ./integrations/nixos.nix;
        pi = import ./integrations/nixos.nix;
      };

      nixDarwinModules = {
        default = import ./integrations/darwin.nix;
        pi = import ./integrations/darwin.nix;
      };

      homeModules = {
        default = import ./integrations/home-manager.nix;
        pi = import ./integrations/home-manager.nix;
      };

      # Alias for backward compatibility
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
        learning = {
          path = ./templates/learning;
          description = "Learning & Obsidian vault development shell with Pi";
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
          mkSkill = nixpiLib.mkPiSkill;
          mkPrompt = nixpiLib.mkPiPrompt;
        in
        rec {
          default = nixpiLib.makePi {
            inherit pkgs;
            modules = [
              self.piModules.default
            ];
          };

          learning = nixpiLib.makePi {
            inherit pkgs;
            modules = [
              deep-comprehension-engine.piModules.default
            ];
          };

          legal-research = nixpiLib.makePi {
            inherit pkgs;
            modules = [
              self.piModules.profiles.legalResearch
            ];
          };

          pi-unwrapped = pkgs.callPackage ./packages/pi { };

          echo = pkgs.callPackage ./packages/extensions/echo {
            mkPiExtension = mkExt;
          };
          ripgrep-search = pkgs.callPackage ./packages/extensions/ripgrep-search {
            mkPiExtension = mkExt;
          };
          plan-mode = pkgs.callPackage ./packages/extensions/plan-mode {
            mkPiExtension = mkExt;
          };
          pi-gpt-search = pkgs.callPackage ./packages/extensions/pi-gpt-search {
            mkPiExtension = mkExt;
          };
          obsidian = deep-comprehension-engine.packages.${system}.extension-obsidian;
          research-tools = pkgs.callPackage ./packages/extensions/research-tools {
            mkPiExtension = mkExt;
          };
          antigravity = pkgs.callPackage ./packages/providers/antigravity {
            mkPiExtension = mkExt;
          };
          pi-antigravity = antigravity;

          commit-style = pkgs.callPackage ./packages/skills/commit-style {
            mkPiSkill = mkSkill;
          };
          skill-commit-style = commit-style;

          evidence-ledger = pkgs.callPackage ./packages/evidence-ledger { };
          prompt-research-lawyer-opportunities =
            pkgs.callPackage ./packages/prompts/research-lawyer-opportunities
              {
                mkPiPrompt = mkPrompt;
              };

          obsidian-screenshot = deep-comprehension-engine.packages.${system}.skill-obsidian-screenshot;
          skill-obsidian-screenshot = obsidian-screenshot;
          skill-socratic-tutor = deep-comprehension-engine.packages.${system}.skill-socratic-tutor;
          skill-feynman-technique = deep-comprehension-engine.packages.${system}.skill-feynman-technique;
          skill-active-recall-notes = deep-comprehension-engine.packages.${system}.skill-active-recall-notes;
          skill-literature-deep-dive =
            deep-comprehension-engine.packages.${system}.skill-literature-deep-dive;
          skill-deep-comprehension-engine =
            deep-comprehension-engine.packages.${system}.skill-deep-comprehension-engine;
          skill-gifted-diagnostic-probe =
            deep-comprehension-engine.packages.${system}.skill-gifted-diagnostic-probe;
          skill-paginated-atomic-notes =
            deep-comprehension-engine.packages.${system}.skill-paginated-atomic-notes;
          skill-mermaid-diagrams = deep-comprehension-engine.packages.${system}.skill-mermaid-diagrams;

          skill-legal-pain-discovery = pkgs.callPackage ./packages/skills/legal-pain-discovery {
            mkPiSkill = mkSkill;
          };
          skill-voice-of-customer-mining = pkgs.callPackage ./packages/skills/voice-of-customer-mining {
            mkPiSkill = mkSkill;
          };
          skill-evidence-deduplication = pkgs.callPackage ./packages/skills/evidence-deduplication {
            mkPiSkill = mkSkill;
          };
          skill-legal-market-segmentation = pkgs.callPackage ./packages/skills/legal-market-segmentation {
            mkPiSkill = mkSkill;
          };
          skill-competitor-gap-analysis = pkgs.callPackage ./packages/skills/competitor-gap-analysis {
            mkPiSkill = mkSkill;
          };
          skill-brazil-localization-test = pkgs.callPackage ./packages/skills/brazil-localization-test {
            mkPiSkill = mkSkill;
          };
          skill-opportunity-scoring = pkgs.callPackage ./packages/skills/opportunity-scoring {
            mkPiSkill = mkSkill;
          };
          skill-product-opportunity-report = pkgs.callPackage ./packages/skills/product-opportunity-report {
            mkPiSkill = mkSkill;
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
            obsidianModule = self.piModules.extensions.obsidian;
          };
          invalid-option-tests = pkgs.callPackage ./tests/eval/invalid-option-test.nix {
            inherit nixpiLib;
          };
          build-tests = pkgs.callPackage ./tests/build/build-test.nix {
            inherit nixpiLib;
            obsidianModule = self.piModules.extensions.obsidian;
          };
          hm-tests = pkgs.callPackage ./tests/integration/hm-test.nix { };
          e2e-tests = pkgs.callPackage ./tests/e2e/e2e-test.nix {
            inherit nixpiLib;
          };
          extend-tests = pkgs.callPackage ./tests/build/extend-test.nix {
            inherit nixpiLib;
          };
          factory-tests = pkgs.callPackage ./tests/eval/factory-test.nix {
            inherit nixpiLib;
          };
          nixos-tests = pkgs.callPackage ./tests/integration/nixos-test.nix { };
          darwin-tests = pkgs.callPackage ./tests/integration/darwin-test.nix { };
          legal-research-tests = pkgs.callPackage ./tests/legal-research/legal-research-test.nix {
            inherit nixpiLib;
            legalResearchProfile = self.piModules.profiles.legalResearch;
          };
        }
      );

      legacyPackages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          nixpiLib = import ./lib {
            lib = pkgs.lib;
            inherit pkgs;
          };
        in
        {
          makePiWithModule =
            {
              module ? { },
              modules ? [ ],
              extraSpecialArgs ? { },
            }:
            nixpiLib.makePi {
              inherit pkgs extraSpecialArgs;
              modules = (if module != { } then [ module ] else [ ]) ++ modules;
            };
          makePi =
            modules:
            nixpiLib.makePi {
              inherit pkgs;
              modules = if builtins.isList modules then modules else [ modules ];
            };
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
