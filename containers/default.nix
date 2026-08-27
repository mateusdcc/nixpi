{ pkgs, nixpiLib }:

let
  inherit (pkgs) lib;

  mkScenario =
    {
      name,
      module,
      settingsFilter,
      modelsFilter ? null,
      requiredEnvironment ? null,
    }:
    let
      configuredPi = nixpiLib.makePi {
        inherit pkgs;
        modules = [ module ];
      };
      settingsFile = configuredPi.passthru.settingsJson;
      modelsCheck =
        if modelsFilter == null then
          ""
        else
          ''
            jq -e ${lib.escapeShellArg modelsFilter} ${configuredPi.passthru.modelsJson} >/dev/null
          '';
      requiredCheck = lib.optionalString (requiredEnvironment != null) ''
        unset ${requiredEnvironment}
        if pi --version >"$testRoot/required.out" 2>"$testRoot/required.err"; then
          echo "Pi started without ${requiredEnvironment}" >&2
          exit 1
        fi
        grep -q "required environment variable ${requiredEnvironment} is not set" "$testRoot/required.err"
        export ${requiredEnvironment}=ci-placeholder
      '';
      testScript = pkgs.writeShellApplication {
        name = "test-nixpi-${name}";
        runtimeInputs = [
          configuredPi
          pkgs.coreutils
          pkgs.gnugrep
          pkgs.jq
        ];
        text = ''
          testRoot="''${TMPDIR:-/tmp}/nixpi-${name}"
          rm -rf "$testRoot"
          mkdir -p "$testRoot/home"
          export HOME="$testRoot/home"
          export XDG_DATA_HOME="$HOME/.local/share"
          export PI_OFFLINE=1
          export PI_SKIP_VERSION_CHECK=1
          export PI_TELEMETRY=0

          ${requiredCheck}

          versionOutput="$(pi --version 2>&1)"
          test -n "$versionOutput"
          jq -e ${lib.escapeShellArg settingsFilter} ${settingsFile} >/dev/null
          ${modelsCheck}
          test -L "$XDG_DATA_HOME/nixpi/agent/settings.json"
          echo "${name}: $versionOutput"
        '';
      };
    in
    {
      image = pkgs.dockerTools.buildLayeredImage {
        name = "nixpi-ci-${name}";
        tag = "edge";
        contents = [ testScript ];
        extraCommands = ''
          mkdir -m 1777 tmp
        '';
        config = {
          Entrypoint = [ "${testScript}/bin/test-nixpi-${name}" ];
          Env = [
            "HOME=/tmp/home"
            "TMPDIR=/tmp"
          ];
          User = "65532:65532";
          WorkingDir = "/tmp";
          Labels."io.nixpi.scenario" = name;
        };
      };

      test = pkgs.runCommand "nixpi-container-${name}-test" { nativeBuildInputs = [ testScript ]; } ''
        test-nixpi-${name} > "$out"
      '';
    };

  scenarios = {
    minimal = mkScenario {
      name = "minimal";
      settingsFilter = "(.packages | length) == 0 and (.skills | length) == 0";
      module.programs.pi = {
        enable = true;
        settings.defaultProvider = "openai";
      };
    };

    features = mkScenario {
      name = "features";
      settingsFilter = "(.packages | length) == 3 and (.skills | length) == 1";
      module.programs.pi = {
        enable = true;
        settings.defaultProvider = "anthropic";
        extensions = {
          echo.enable = true;
          ripgrep-search.enable = true;
          plan-mode.enable = true;
        };
        skills.commit-style.enable = true;
      };
    };

    provider = mkScenario {
      name = "provider";
      settingsFilter = ''.defaultProvider == "local"'';
      modelsFilter = ''
        .providers.local.baseUrl == "http://localhost:11434/v1"
        and .providers.local.models[0].id == "test-model"
      '';
      requiredEnvironment = "NIXPI_DOCKER_TOKEN";
      module.programs.pi = {
        enable = true;
        settings.defaultProvider = "local";
        environment.required = [ "NIXPI_DOCKER_TOKEN" ];
        providers.local = {
          baseUrl = "http://localhost:11434/v1";
          api = "openai-completions";
          models = [ { id = "test-model"; } ];
        };
      };
    };
  };
in
{
  images = lib.mapAttrs' (
    name: scenario: lib.nameValuePair "docker-${name}" scenario.image
  ) scenarios;
  checks = lib.mapAttrs' (
    name: scenario: lib.nameValuePair "container-${name}-tests" scenario.test
  ) scenarios;
}
