{
  self,
  deepComprehensionEngine,
  deprecated,
}:

{
  piModules = {
    default = import ../modules;
    core = import ../modules/core/package.nix;
    base = import ../modules/core;
    profiles = {
      minimal = import ../modules/profiles/minimal.nix;
      research = import ../modules/profiles/research.nix;
      legalResearch = import ../modules/profiles/legal-research.nix;
      learning =
        deprecated "piModules.profiles.learning" "deep-comprehension-engine.piModules.default"
          deepComprehensionEngine.piModules.default;
    };
    extensions = {
      echo = import ../modules/extensions/echo.nix;
      ripgrep-search = import ../modules/extensions/ripgrep-search.nix;
      plan-mode = import ../modules/extensions/plan-mode.nix;
      pi-gpt-search = import ../modules/extensions/pi-gpt-search.nix;
      researchTools = import ../modules/extensions/research-tools.nix;
      obsidian =
        deprecated "piModules.extensions.obsidian" "deep-comprehension-engine.piModules.extensions.obsidian"
          deepComprehensionEngine.piModules.extensions.obsidian;
    };
    skills = {
      commit-style = import ../modules/skills/commit-style.nix;
      legalPainDiscovery = import ../modules/skills/legal-pain-discovery.nix;
      voiceOfCustomerMining = import ../modules/skills/voice-of-customer-mining.nix;
      evidenceDeduplication = import ../modules/skills/evidence-deduplication.nix;
      legalMarketSegmentation = import ../modules/skills/legal-market-segmentation.nix;
      competitorGapAnalysis = import ../modules/skills/competitor-gap-analysis.nix;
      brazilLocalizationTest = import ../modules/skills/brazil-localization-test.nix;
      opportunityScoring = import ../modules/skills/opportunity-scoring.nix;
      productOpportunityReport = import ../modules/skills/product-opportunity-report.nix;
      obsidianScreenshot =
        deprecated "piModules.skills.obsidianScreenshot"
          "deep-comprehension-engine.piModules.skills.obsidianScreenshot"
          deepComprehensionEngine.piModules.skills.obsidianScreenshot;
      socraticTutor =
        deprecated "piModules.skills.socraticTutor"
          "deep-comprehension-engine.piModules.skills.socraticTutor"
          deepComprehensionEngine.piModules.skills.socraticTutor;
      feynmanTechnique =
        deprecated "piModules.skills.feynmanTechnique"
          "deep-comprehension-engine.piModules.skills.feynmanTechnique"
          deepComprehensionEngine.piModules.skills.feynmanTechnique;
      activeRecallNotes =
        deprecated "piModules.skills.activeRecallNotes"
          "deep-comprehension-engine.piModules.skills.activeRecallNotes"
          deepComprehensionEngine.piModules.skills.activeRecallNotes;
      literatureDeepDive =
        deprecated "piModules.skills.literatureDeepDive"
          "deep-comprehension-engine.piModules.skills.literatureDeepDive"
          deepComprehensionEngine.piModules.skills.literatureDeepDive;
      deepComprehensionEngine =
        deprecated "piModules.skills.deepComprehensionEngine"
          "deep-comprehension-engine.piModules.skills.deepComprehensionEngine"
          deepComprehensionEngine.piModules.skills.deepComprehensionEngine;
      giftedDiagnosticProbe =
        deprecated "piModules.skills.giftedDiagnosticProbe"
          "deep-comprehension-engine.piModules.skills.giftedDiagnosticProbe"
          deepComprehensionEngine.piModules.skills.giftedDiagnosticProbe;
      paginatedAtomicNotes =
        deprecated "piModules.skills.paginatedAtomicNotes"
          "deep-comprehension-engine.piModules.skills.paginatedAtomicNotes"
          deepComprehensionEngine.piModules.skills.paginatedAtomicNotes;
      mermaidDiagrams =
        deprecated "piModules.skills.mermaidDiagrams"
          "deep-comprehension-engine.piModules.skills.mermaidDiagrams"
          deepComprehensionEngine.piModules.skills.mermaidDiagrams;
    };
    providers.antigravity = import ../modules/providers/antigravity.nix;
  };

  nixosModules = {
    default = import ../integrations/nixos.nix;
    pi = import ../integrations/nixos.nix;
  };

  nixDarwinModules = {
    default = import ../integrations/darwin.nix;
    pi = import ../integrations/darwin.nix;
  };

  homeModules = {
    default = import ../integrations/home-manager.nix;
    pi = import ../integrations/home-manager.nix;
  };

  homeManagerModules = self.homeModules;
}
