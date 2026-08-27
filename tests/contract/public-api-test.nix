{
  pkgs,
  self,
}:

let
  publicLib = self.lib;
  skill = publicLib.mkPiSkill {
    inherit pkgs;
    name = "contract-skill";
    description = "Public API contract skill";
    content = "Contract content";
  };
  prompt = publicLib.mkPiPrompt {
    inherit pkgs;
    name = "contract-prompt";
    content = "Contract content";
  };
  theme = publicLib.mkPiTheme {
    inherit pkgs;
    name = "contract-theme";
    colors = {
      background = "#000000";
    };
  };
  provider = publicLib.mkPiProvider {
    inherit pkgs;
    name = "contract-provider";
    baseUrl = "http://localhost";
    models = [ "contract-model" ];
  };
  extension = publicLib.mkPiExtension {
    inherit pkgs;
    pname = "contract-extension";
    src = pkgs.writeTextDir "extensions/index.js" "export default {};";
  };

  compatibilityPathsExist =
    self.piModules.extensions ? obsidian
    && self.piModules.profiles ? learning
    && self.piModules.skills ? activeRecallNotes
    && self.piModules.skills ? deepComprehensionEngine
    && self.piModules.skills ? feynmanTechnique
    && self.piModules.skills ? giftedDiagnosticProbe
    && self.piModules.skills ? literatureDeepDive
    && self.piModules.skills ? mermaidDiagrams
    && self.piModules.skills ? obsidianScreenshot
    && self.piModules.skills ? paginatedAtomicNotes
    && self.piModules.skills ? socraticTutor
    && self.templates ? learning
    && self.packages.${pkgs.system} ? learning
    && self.packages.${pkgs.system} ? obsidian
    && self.packages.${pkgs.system} ? obsidian-screenshot
    && self.packages.${pkgs.system} ? skill-active-recall-notes
    && self.packages.${pkgs.system} ? skill-deep-comprehension-engine
    && self.packages.${pkgs.system} ? skill-feynman-technique
    && self.packages.${pkgs.system} ? skill-gifted-diagnostic-probe
    && self.packages.${pkgs.system} ? skill-literature-deep-dive
    && self.packages.${pkgs.system} ? skill-mermaid-diagrams
    && self.packages.${pkgs.system} ? skill-obsidian-screenshot
    && self.packages.${pkgs.system} ? skill-paginated-atomic-notes
    && self.packages.${pkgs.system} ? skill-socratic-tutor;
in
assert compatibilityPathsExist;
assert provider.name == "contract-provider";
assert provider.models.contract-model.id == "contract-model";
pkgs.runCommand "nixpi-public-api-contract" { } ''
  test -e ${skill}
  test -e ${prompt}
  test -e ${theme}
  test -e ${extension}
  touch "$out"
''
