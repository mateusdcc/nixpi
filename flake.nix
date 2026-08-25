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
          learning = import ./modules/profiles/learning.nix;
          legalResearch = import ./modules/profiles/legal-research.nix;
        };
        extensions = {
          echo = import ./modules/extensions/echo.nix;
          ripgrep-search = import ./modules/extensions/ripgrep-search.nix;
          plan-mode = import ./modules/extensions/plan-mode.nix;
          pi-gpt-search = import ./modules/extensions/pi-gpt-search.nix;
          obsidian = import ./modules/extensions/obsidian.nix;
          researchTools = import ./modules/extensions/research-tools.nix;
        };
        skills = {
          commit-style = import ./modules/skills/commit-style.nix;
          obsidianScreenshot = import ./modules/skills/obsidian-screenshot.nix;
          socraticTutor = import ./modules/skills/socratic-tutor.nix;
          feynmanTechnique = import ./modules/skills/feynman-technique.nix;
          activeRecallNotes = import ./modules/skills/active-recall-notes.nix;
          literatureDeepDive = import ./modules/skills/literature-deep-dive.nix;
          giftedDiagnosticProbe = import ./modules/skills/gifted-diagnostic-probe.nix;
          paginatedAtomicNotes = import ./modules/skills/paginated-atomic-notes.nix;
          mermaidDiagrams = import ./modules/skills/mermaid-diagrams.nix;
          legalPainDiscovery = import ./modules/skills/legal-pain-discovery.nix;
          voiceOfCustomerMining = import ./modules/skills/voice-of-customer-mining.nix;
          evidenceDeduplication = import ./modules/skills/evidence-deduplication.nix;
          legalMarketSegmentation = import ./modules/skills/legal-market-segmentation.nix;
          competitorGapAnalysis = import ./modules/skills/competitor-gap-analysis.nix;
          brazilLocalizationTest = import ./modules/skills/brazil-localization-test.nix;
          opportunityScoring = import ./modules/skills/opportunity-scoring.nix;
          productOpportunityReport = import ./modules/skills/product-opportunity-report.nix;
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
          antigravityPkg = pkgs.callPackage ./packages/providers/antigravity {
            mkPiExtension = mkExt;
          };
          evidenceLedgerPkg = pkgs.callPackage ./packages/evidence-ledger { };
          researchToolsPkg = pkgs.callPackage ./packages/extensions/research-tools {
            mkPiExtension = mkExt;
          };
          promptResearchPkg = pkgs.callPackage ./packages/prompts/research-lawyer-opportunities { };
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

          legal-research = nixpiLib.makePi {
            inherit pkgs;
            modules = [
              self.piModules.profiles.legalResearch
              (
                { config, ... }:
                {
                  programs.pi = {
                    providers.antigravity.enable = true;
                    settings = {
                      defaultProvider = config.programs.pi.providers.antigravity;
                      defaultModel = config.programs.pi.providers.antigravity.models."gemini-3.7-flash";
                    };
                  };
                }
              )
            ];
          };

          learning = nixpiLib.makePi {
            inherit pkgs;
            modules = [
              self.piModules.profiles.learning
              (
                { config, ... }:
                {
                  programs.pi = {
                    providers.antigravity.enable = true;
                    settings = {
                      defaultProvider = config.programs.pi.providers.antigravity;
                      defaultModel = config.programs.pi.providers.antigravity.models."gemini-3.7-flash";
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
          research-tools = researchToolsPkg;
          evidence-ledger = evidenceLedgerPkg;
          prompt-research-lawyer-opportunities = promptResearchPkg;

          antigravity = antigravityPkg;
          pi-antigravity = antigravityPkg;

          commit-style = pkgs.callPackage ./packages/skills/commit-style {
            mkPiSkill = nixpiLib.mkPiSkill;
          };
          skill-commit-style = pkgs.callPackage ./packages/skills/commit-style {
            mkPiSkill = nixpiLib.mkPiSkill;
          };
          obsidian-screenshot = pkgs.callPackage ./packages/skills/obsidian-screenshot {
            mkPiSkill = nixpiLib.mkPiSkill;
          };
          skill-obsidian-screenshot = pkgs.callPackage ./packages/skills/obsidian-screenshot {
            mkPiSkill = nixpiLib.mkPiSkill;
          };

          skill-socratic-tutor = pkgs.callPackage ./packages/skills/socratic-tutor {
            mkPiSkill = nixpiLib.mkPiSkill;
          };
          skill-feynman-technique = pkgs.callPackage ./packages/skills/feynman-technique {
            mkPiSkill = nixpiLib.mkPiSkill;
          };
          skill-active-recall-notes = pkgs.callPackage ./packages/skills/active-recall-notes {
            mkPiSkill = nixpiLib.mkPiSkill;
          };
          skill-literature-deep-dive = pkgs.callPackage ./packages/skills/literature-deep-dive {
            mkPiSkill = nixpiLib.mkPiSkill;
          };
          skill-gifted-diagnostic-probe = pkgs.callPackage ./packages/skills/gifted-diagnostic-probe {
            mkPiSkill = nixpiLib.mkPiSkill;
          };
          skill-paginated-atomic-notes = pkgs.callPackage ./packages/skills/paginated-atomic-notes {
            mkPiSkill = nixpiLib.mkPiSkill;
          };
          skill-mermaid-diagrams = pkgs.callPackage ./packages/skills/mermaid-diagrams {
            mkPiSkill = nixpiLib.mkPiSkill;
          };

          skill-legal-pain-discovery = pkgs.callPackage ./packages/skills/legal-pain-discovery {
            mkPiSkill = nixpiLib.mkPiSkill;
          };
          skill-voice-of-customer-mining = pkgs.callPackage ./packages/skills/voice-of-customer-mining {
            mkPiSkill = nixpiLib.mkPiSkill;
          };
          skill-evidence-deduplication = pkgs.callPackage ./packages/skills/evidence-deduplication {
            mkPiSkill = nixpiLib.mkPiSkill;
          };
          skill-legal-market-segmentation = pkgs.callPackage ./packages/skills/legal-market-segmentation {
            mkPiSkill = nixpiLib.mkPiSkill;
          };
          skill-competitor-gap-analysis = pkgs.callPackage ./packages/skills/competitor-gap-analysis {
            mkPiSkill = nixpiLib.mkPiSkill;
          };
          skill-brazil-localization-test = pkgs.callPackage ./packages/skills/brazil-localization-test {
            mkPiSkill = nixpiLib.mkPiSkill;
          };
          skill-opportunity-scoring = pkgs.callPackage ./packages/skills/opportunity-scoring {
            mkPiSkill = nixpiLib.mkPiSkill;
          };
          skill-product-opportunity-report = pkgs.callPackage ./packages/skills/product-opportunity-report {
            mkPiSkill = nixpiLib.mkPiSkill;
          };
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          configuredPi = self.packages.${system}.legal-research;
        in
        {
          default = pkgs.mkShell {
            packages = [
              configuredPi
              pkgs.nixfmt
              pkgs.git
              pkgs.ripgrep
              pkgs.duckdb
              pkgs.python3
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
          legal-research-tests = pkgs.callPackage ./tests/legal-research/legal-research-test.nix {
            inherit nixpiLib;
            legalResearchProfile = self.piModules.profiles.legalResearch;
          };
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
