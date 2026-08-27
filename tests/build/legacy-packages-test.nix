{
  pkgs,
  legacyPackages,
}:

let
  lib = pkgs.lib;

  # Test makePi builder
  piFromMakePi = legacyPackages.makePi {
    programs.pi = {
      enable = true;
      settings.defaultProvider = "openai";
      extensions.echo.enable = true;
    };
  };

  # Test makePiWithModule builder
  piFromMakePiWithModule = legacyPackages.makePiWithModule {
    module = {
      programs.pi = {
        enable = true;
        settings.defaultProvider = "anthropic";
        skills.commit-style.enable = true;
      };
    };
  };

  # Test extending a package built with makePiWithModule
  extendedFromLegacy = piFromMakePiWithModule.extend {
    programs.pi.environment.variables.LEGACY_EXTENDED = "1";
  };

  correctProvider1 = piFromMakePi.passthru.config.programs.pi.settings.defaultProvider == "openai";
  correctProvider2 =
    piFromMakePiWithModule.passthru.config.programs.pi.settings.defaultProvider == "anthropic";
  correctExtendedEnv =
    extendedFromLegacy.passthru.config.programs.pi.environment.variables.LEGACY_EXTENDED == "1";

  allPass = correctProvider1 && correctProvider2 && correctExtendedEnv;
in
pkgs.runCommand "nixpi-legacy-packages-test" { } ''
  ${lib.optionalString (!allPass) "echo 'Legacy packages builder test failed' >&2; exit 1"}
  test -x "${piFromMakePi}/bin/pi"
  test -x "${piFromMakePiWithModule}/bin/pi"
  test -x "${extendedFromLegacy}/bin/pi"
  echo "legacyPackages builders (makePi, makePiWithModule) tested and verified successfully" > "$out"
''
