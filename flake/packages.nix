{
  self,
  nixpkgs,
  systems,
  deepComprehensionEngine,
  deprecated,
}:

{
  packages = nixpkgs.lib.genAttrs systems (
    system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      nixpiLib = import ../lib {
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
        modules = [ self.piModules.default ];
      };

      legal-research = nixpiLib.makePi {
        inherit pkgs;
        modules = [ self.piModules.profiles.legalResearch ];
      };

      docs = pkgs.callPackage ../docs { inherit nixpiLib; };

      learning =
        deprecated "packages.${system}.learning" "deep-comprehension-engine.packages.${system}.default"
          (
            nixpiLib.makePi {
              inherit pkgs;
              modules = [ deepComprehensionEngine.piModules.default ];
            }
          );

      pi-unwrapped = pkgs.callPackage ../packages/pi { };

      echo = pkgs.callPackage ../packages/extensions/echo { mkPiExtension = mkExt; };
      ripgrep-search = pkgs.callPackage ../packages/extensions/ripgrep-search { mkPiExtension = mkExt; };
      plan-mode = pkgs.callPackage ../packages/extensions/plan-mode { mkPiExtension = mkExt; };
      pi-gpt-search = pkgs.callPackage ../packages/extensions/pi-gpt-search { mkPiExtension = mkExt; };
      research-tools = pkgs.callPackage ../packages/extensions/research-tools { mkPiExtension = mkExt; };
      obsidian =
        deprecated "packages.${system}.obsidian"
          "deep-comprehension-engine.packages.${system}.extension-obsidian"
          deepComprehensionEngine.packages.${system}.extension-obsidian;
      antigravity = pkgs.callPackage ../packages/providers/antigravity { mkPiExtension = mkExt; };
      pi-antigravity = antigravity;

      commit-style = pkgs.callPackage ../packages/skills/commit-style { mkPiSkill = mkSkill; };
      skill-commit-style = commit-style;

      evidence-ledger = pkgs.callPackage ../packages/evidence-ledger { };
      prompt-research-lawyer-opportunities =
        pkgs.callPackage ../packages/prompts/research-lawyer-opportunities
          { mkPiPrompt = mkPrompt; };

      skill-legal-pain-discovery = pkgs.callPackage ../packages/skills/legal-pain-discovery {
        mkPiSkill = mkSkill;
      };
      skill-voice-of-customer-mining = pkgs.callPackage ../packages/skills/voice-of-customer-mining {
        mkPiSkill = mkSkill;
      };
      skill-evidence-deduplication = pkgs.callPackage ../packages/skills/evidence-deduplication {
        mkPiSkill = mkSkill;
      };
      skill-legal-market-segmentation = pkgs.callPackage ../packages/skills/legal-market-segmentation {
        mkPiSkill = mkSkill;
      };
      skill-competitor-gap-analysis = pkgs.callPackage ../packages/skills/competitor-gap-analysis {
        mkPiSkill = mkSkill;
      };
      skill-brazil-localization-test = pkgs.callPackage ../packages/skills/brazil-localization-test {
        mkPiSkill = mkSkill;
      };
      skill-opportunity-scoring = pkgs.callPackage ../packages/skills/opportunity-scoring {
        mkPiSkill = mkSkill;
      };
      skill-product-opportunity-report = pkgs.callPackage ../packages/skills/product-opportunity-report {
        mkPiSkill = mkSkill;
      };

      obsidian-screenshot =
        deprecated "packages.${system}.obsidian-screenshot"
          "deep-comprehension-engine.packages.${system}.skill-obsidian-screenshot"
          deepComprehensionEngine.packages.${system}.skill-obsidian-screenshot;
      skill-obsidian-screenshot = obsidian-screenshot;
      skill-socratic-tutor =
        deprecated "packages.${system}.skill-socratic-tutor"
          "deep-comprehension-engine.packages.${system}.skill-socratic-tutor"
          deepComprehensionEngine.packages.${system}.skill-socratic-tutor;
      skill-feynman-technique =
        deprecated "packages.${system}.skill-feynman-technique"
          "deep-comprehension-engine.packages.${system}.skill-feynman-technique"
          deepComprehensionEngine.packages.${system}.skill-feynman-technique;
      skill-active-recall-notes =
        deprecated "packages.${system}.skill-active-recall-notes"
          "deep-comprehension-engine.packages.${system}.skill-active-recall-notes"
          deepComprehensionEngine.packages.${system}.skill-active-recall-notes;
      skill-literature-deep-dive =
        deprecated "packages.${system}.skill-literature-deep-dive"
          "deep-comprehension-engine.packages.${system}.skill-literature-deep-dive"
          deepComprehensionEngine.packages.${system}.skill-literature-deep-dive;
      skill-deep-comprehension-engine =
        deprecated "packages.${system}.skill-deep-comprehension-engine"
          "deep-comprehension-engine.packages.${system}.skill-deep-comprehension-engine"
          deepComprehensionEngine.packages.${system}.skill-deep-comprehension-engine;
      skill-gifted-diagnostic-probe =
        deprecated "packages.${system}.skill-gifted-diagnostic-probe"
          "deep-comprehension-engine.packages.${system}.skill-gifted-diagnostic-probe"
          deepComprehensionEngine.packages.${system}.skill-gifted-diagnostic-probe;
      skill-paginated-atomic-notes =
        deprecated "packages.${system}.skill-paginated-atomic-notes"
          "deep-comprehension-engine.packages.${system}.skill-paginated-atomic-notes"
          deepComprehensionEngine.packages.${system}.skill-paginated-atomic-notes;
      skill-mermaid-diagrams =
        deprecated "packages.${system}.skill-mermaid-diagrams"
          "deep-comprehension-engine.packages.${system}.skill-mermaid-diagrams"
          deepComprehensionEngine.packages.${system}.skill-mermaid-diagrams;
    }
  );
}
