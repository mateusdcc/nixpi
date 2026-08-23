{ pkgs, nixpiLib }:

let
  testSkill = nixpiLib.mkPiSkill {
    name = "test-skill";
    description = "Test skill description";
    content = "Test skill instructions";
  };

  testPrompt = nixpiLib.mkPiPrompt {
    name = "test-prompt";
    description = "Test prompt description";
    argumentHint = "<target>";
    content = "Review the target: $1";
  };

  testTheme = nixpiLib.mkPiTheme {
    name = "test-theme";
    colors = {
      primary = "#00ff00";
    };
  };

  customProvider = nixpiLib.mkPiProvider {
    name = "test-provider";
    baseUrl = "https://test.provider.local/v1";
    models = [
      {
        id = "test-model";
        name = "Test Model";
      }
    ];
  };

  configuredPi = nixpiLib.makePi {
    inherit pkgs;
    modules = [
      {
        programs.pi = {
          enable = true;
          skills.commit-style.enable = true;
          rawSkills = [ testSkill ];
          prompts = [ testPrompt ];
          themes = [ testTheme ];
          settings.defaultProvider = customProvider;
          providers = {
            test-provider = customProvider;
            antigravity.enable = true;
          };
          extensions.echo.enable = true;
          extensions.ripgrep-search.enable = true;
          extensions.obsidian.enable = true;
        };
      }
    ];
  };
in
pkgs.runCommand "nixpi-build-test" { } ''
  test -x "${configuredPi}/bin/pi"
  test -f "${configuredPi.settingsJson}"
  test -f "${configuredPi.modelsJson}"
  grep -q "commit-style" "${configuredPi.settingsJson}"
  grep -q "test-skill" "${configuredPi.settingsJson}"
  echo "Build test successfully verified configured package, skills, and settings" > "$out"
''
