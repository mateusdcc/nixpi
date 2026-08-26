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

  # Extend basePi dynamically with single module
  extendedPi = basePi.extend {
    programs.pi = {
      skills.commit-style.enable = true;
      environment.variables.PI_EXTENDED_FLAG = "active";
    };
  };

  # Further chain extension with list of modules
  chainedPi = extendedPi.extend [
    {
      programs.pi.extensions.ripgrep-search.enable = true;
    }
    {
      programs.pi.settings.theme = "custom-extended-theme";
    }
  ];

  # Passthru inspection
  hasPassthruConfig = basePi ? passthru && basePi.passthru ? config;
  hasPassthruOptions = basePi ? passthru && basePi.passthru ? options;
  hasPassthruUnwrapped = basePi ? passthru && basePi.passthru ? unwrapped;
  hasPassthruExtend = basePi ? passthru && basePi.passthru ? extend;

  baseSettings = basePi.passthru.config.programs.pi.settings.defaultProvider == "anthropic";
  extendedHasSkill = extendedPi.passthru.config.programs.pi.skills.commit-style.enable == true;
  extendedHasEnv =
    extendedPi.passthru.config.programs.pi.environment.variables.PI_EXTENDED_FLAG == "active";
  chainedHasRipgrep = chainedPi.passthru.config.programs.pi.extensions.ripgrep-search.enable == true;
  chainedHasTheme = chainedPi.passthru.config.programs.pi.settings.theme == "custom-extended-theme";

  allPass =
    hasPassthruConfig
    && hasPassthruOptions
    && hasPassthruUnwrapped
    && hasPassthruExtend
    && baseSettings
    && extendedHasSkill
    && extendedHasEnv
    && chainedHasRipgrep
    && chainedHasTheme;
in
pkgs.runCommand "nixpi-extend-test" { } ''
  ${pkgs.lib.optionalString (!allPass) "echo 'Extend test validation failed' >&2; exit 1"}
  test -x "${basePi}/bin/pi"
  test -x "${extendedPi}/bin/pi"
  test -x "${chainedPi}/bin/pi"
  grep -q "commit-style" "${extendedPi.settingsJson}"
  grep -q "custom-extended-theme" "${chainedPi.settingsJson}"
  echo "Extend composability test successfully verified passthru.extend, passthru.config, passthru.options, and chaining" > "$out"
''
