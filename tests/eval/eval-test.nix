{ pkgs, nixpiLib }:

let
  lib = pkgs.lib;

  customProviderObj = nixpiLib.mkPiProvider {
    name = "custom-created";
    baseUrl = "https://custom.provider.test";
    models = [
      {
        id = "custom-model-1";
        name = "Custom Model 1";
      }
    ];
  };

  # Test 1: Full configuration evaluation with object references
  testEval = nixpiLib.evalPi {
    inherit pkgs;
    modules = [
      (
        { config, ... }:
        {
          programs.pi = {
            enable = true;
            providers = {
              antigravity.enable = true;
              custom-created = customProviderObj;
            };
            settings = {
              # Pass provider object directly
              defaultProvider = config.programs.pi.providers.antigravity;
              # Pass model object directly
              defaultModel = config.programs.pi.providers.antigravity.models."gemini-3.7-flash";
              defaultThinkingLevel = "high";
              theme = "dark";
            };
            extensions = {
              echo.enable = true;
              ripgrep-search.enable = true;
              plan-mode = {
                enable = true;
                mode = "thorough";
                maxSteps = 25;
                autoApprove = true;
              };
              obsidian = {
                enable = true;
                defaultVault = "/path/to/my-vault";
                apiUrl = "https://127.0.0.1:27124";
              };
            };
            skills = {
              commit-style.enable = true;
            };
            environment = {
              variables = {
                PI_TEST_VAR = "hello-nixpi";
              };
              required = [
                "CUSTOM_API_KEY"
              ];
            };
          };
        }
      )
    ];
  };

  cfg = testEval.config.programs.pi;

  # Assertions
  hasRipgrep = lib.any (p: p.pname or p.name == "ripgrep") cfg.finalRuntimePackages;
  hasGit = lib.any (p: p.pname or p.name == "git") cfg.finalRuntimePackages;
  hasCurl = lib.any (p: p.pname or p.name == "curl") cfg.finalRuntimePackages;
  hasEchoPkg = lib.length cfg.finalRuntimePackages >= 1;
  hasPlanModeSetting = cfg.settings.planMode.mode == "thorough";
  hasObsidianEnv = cfg.environment.variables.OBSIDIAN_DEFAULT_VAULT == "/path/to/my-vault";
  hasAntigravityProvider = cfg.providers.antigravity.package != null;
  hasCustomProvider = cfg.providers.custom-created.baseUrl == "https://custom.provider.test";
  hasCorrectDefaultProvider = cfg.settings.defaultProvider == "antigravity";
  hasCorrectDefaultModel = cfg.settings.defaultModel == "gemini-3.7-flash";
  hasCommitStyleSkill = cfg.skills ? commit-style && cfg.skills.commit-style.package != null;

  # Check that built-in providers are pre-populated on the providers object
  hasOpenAIProvider = cfg.providers ? openai && cfg.providers.openai.models ? "gpt-4o";

  allChecksPass =
    hasRipgrep
    && hasGit
    && hasCurl
    && hasEchoPkg
    && hasPlanModeSetting
    && hasObsidianEnv
    && hasAntigravityProvider
    && hasCustomProvider
    && hasCorrectDefaultProvider
    && hasCorrectDefaultModel
    && hasCommitStyleSkill
    && hasOpenAIProvider;
in
pkgs.runCommand "nixpi-eval-test" { } ''
  ${lib.optionalString (!allChecksPass) "echo 'Eval assertion failed' >&2; exit 1"}
  echo "All eval assertions passed" > "$out"
''
