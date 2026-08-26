{
  pkgs,
  nixpiLib,
}:

let
  basePi = nixpiLib.makePi {
    inherit pkgs;
    modules = [
      {
        programs.pi = {
          enable = true;
          settings.defaultProvider = "anthropic";
          extensions.echo.enable = true;
        };
      }
    ];
  };

  # Extend basePi dynamically with additional configuration
  extendedPi = basePi.extend {
    programs.pi = {
      skills.commit-style.enable = true;
      environment.variables.PI_EXTENDED_FLAG = "active";
    };
  };

  # Further chain extension
  chainedPi = extendedPi.extend {
    programs.pi = {
      extensions.ripgrep-search.enable = true;
    };
  };

  baseSettings = basePi.passthru.config.programs.pi.settings.defaultProvider == "anthropic";
  extendedHasSkill = extendedPi.passthru.config.programs.pi.skills.commit-style.enable == true;
  extendedHasEnv =
    extendedPi.passthru.config.programs.pi.environment.variables.PI_EXTENDED_FLAG == "active";
  chainedHasRipgrep = chainedPi.passthru.config.programs.pi.extensions.ripgrep-search.enable == true;

  allPass = baseSettings && extendedHasSkill && extendedHasEnv && chainedHasRipgrep;
in
pkgs.runCommand "nixpi-extend-test" { } ''
  ${pkgs.lib.optionalString (!allPass) "echo 'Extend test validation failed' >&2; exit 1"}
  test -x "${basePi}/bin/pi"
  test -x "${extendedPi}/bin/pi"
  test -x "${chainedPi}/bin/pi"
  grep -q "commit-style" "${extendedPi.settingsJson}"
  echo "Extend composability test successfully verified passthru.extend functionality" > "$out"
''
