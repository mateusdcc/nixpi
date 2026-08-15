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

  configuredPi = nixpiLib.makePi {
    inherit pkgs;
    modules = [
      {
        programs.pi = {
          enable = true;
          skills = [ testSkill ];
          prompts = [ testPrompt ];
          themes = [ testTheme ];
          extensions.echo.enable = true;
          extensions.ripgrep-search.enable = true;
        };
      }
    ];
  };
in
pkgs.runCommand "nixpi-build-test" { } ''
  test -x "${configuredPi}/bin/pi"
  test -f "${configuredPi.settingsJson}"
  echo "Build test successfully verified configured package and settings" > "$out"
''
