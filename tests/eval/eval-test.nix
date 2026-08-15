{ pkgs, nixpiLib }:

let
  lib = pkgs.lib;

  # Test 1: Full configuration evaluation
  testEval = nixpiLib.evalPi {
    inherit pkgs;
    modules = [
      {
        programs.pi = {
          enable = true;
          settings = {
            defaultProvider = "custom-antigravity";
            defaultModel = "gemini-3.7-flash";
            defaultThinkingLevel = "high";
            theme = "dark";
          };
          providers.custom-antigravity = {
            baseUrl = "https://api.antigravity.test/v1";
            api = "openai-completions";
            models = [
              {
                id = "gemini-3.7-flash";
                name = "Antigravity Flash";
                reasoning = true;
              }
            ];
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
    ];
  };

  cfg = testEval.config.programs.pi;

  # Assertions
  hasRipgrep = lib.any (p: p.pname or p.name == "ripgrep") cfg.finalRuntimePackages;
  hasEchoPkg = lib.length cfg.finalRuntimePackages >= 1;
  hasPlanModeSetting = cfg.settings.planMode.mode == "thorough";
  hasProvider = cfg.providers.custom-antigravity.baseUrl == "https://api.antigravity.test/v1";

  allChecksPass = hasRipgrep && hasEchoPkg && hasPlanModeSetting && hasProvider;
in
pkgs.runCommand "nixpi-eval-test" { } ''
  ${lib.optionalString (!allChecksPass) "echo 'Eval assertion failed' >&2; exit 1"}
  echo "All eval assertions passed" > "$out"
''
