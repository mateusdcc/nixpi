{ pkgs, nixpiLib }:

let
  testEntrypointTs = pkgs.writeText "custom-entrypoint.ts" ''
    export default function(pi: any) {
      const tsNum: number = 777;
      console.error(`CUSTOM_ENTRYPOINT_TS_LOADED:''${tsNum}`);
    }
  '';

  configuredPi = nixpiLib.makePi {
    inherit pkgs;
    modules = [
      {
        programs.pi = {
          enable = true;
          settings = {
            defaultProvider = "openai";
            theme = "custom-e2e-theme";
          };
          extensions = {
            echo.enable = true;
            ripgrep-search.enable = true;
          };
          customExtensions = {
            inline-ts = {
              enable = true;
              content = ''
                export default function(pi: any) {
                  const x: number = 999;
                  console.error(`CUSTOM_INLINE_TS_LOADED:''${x}`);
                }
              '';
              runtimePackages = [ pkgs.jq ];
              runtimeEnvironment = {
                CUSTOM_TS_EXT_ENV = "loaded-successfully";
              };
            };
            entrypoint-ts = {
              enable = true;
              entrypoint = testEntrypointTs;
            };
            disabled-ext = {
              enable = false;
              content = ''
                export default function() {
                  console.error("DISABLED_EXT_LOADED");
                }
              '';
            };
          };
          customSkills = {
            e2e-skill = {
              enable = true;
              description = "E2E custom skill";
              content = "# E2E Custom Skill Instructions";
            };
            disabled-skill = {
              enable = false;
              description = "Disabled skill";
            };
          };
          customPrompts = {
            e2e-prompt = {
              enable = true;
              description = "E2E custom prompt";
              argumentHint = "[arg]";
              content = "E2E Prompt content: $ARGUMENTS";
            };
          };
          customThemes = {
            custom-e2e-theme = {
              enable = true;
              colors = {
                accent = "#ff00ff";
                bg = "#000000";
              };
            };
          };
          environment.variables = {
            PI_TEST_ENV_VAR = "nixpi-verified";
          };
          environment.required = [ "NIXPI_REQUIRED_TEST" ];
        };
      }
    ];
  };
in
pkgs.runCommand "nixpi-e2e-test"
  {
    buildInputs = [ configuredPi ];
  }
  ''
    set -eu

    export HOME="$TMPDIR/fake-home"
    export XDG_DATA_HOME="$TMPDIR/fake-home/.local/share"
    mkdir -p "$HOME" "$XDG_DATA_HOME"

    export PI_OFFLINE=1
    export PI_SKIP_VERSION_CHECK=1
    export PI_TELEMETRY=0

    # 1. Required environment variables fail fast with actionable output
    if "${configuredPi}/bin/pi" --version 2> required-env-error; then
      echo "Error: pi started without its required environment" >&2
      exit 1
    fi
    grep -q "required environment variable NIXPI_REQUIRED_TEST is not set" required-env-error
    export NIXPI_REQUIRED_TEST=verified

    # 2. Test version output
    VERSION_OUTPUT=$("${configuredPi}/bin/pi" --version 2>&1)
    echo "Reported Pi version: $VERSION_OUTPUT"
    if [ -z "$VERSION_OUTPUT" ]; then
      echo "Error: Unexpected empty pi version output" >&2
      exit 1
    fi

    # 3. Verify wrapper script contains ripgrep and jq in PATH
    grep -q "ripgrep" "${configuredPi}/bin/pi" || (echo "Error: ripgrep was not in pi wrapper PATH" >&2; exit 1)
    grep -q "jq" "${configuredPi}/bin/pi" || (echo "Error: jq was not in pi wrapper PATH" >&2; exit 1)

    # 4. Verify wrapper script contains custom runtime environment variable
    grep -q "CUSTOM_TS_EXT_ENV=loaded-successfully" "${configuredPi}/bin/pi" || (echo "Error: CUSTOM_TS_EXT_ENV was not exported in wrapper" >&2; exit 1)

    # 5. Test safe non-network model listing and verify custom TypeScript extension loading
    PI_LOGS=$("${configuredPi}/bin/pi" --list-models 2>&1 || true)
    echo "$PI_LOGS"

    echo "$PI_LOGS" | grep -q "CUSTOM_INLINE_TS_LOADED:999" || (echo "Error: inline TS extension was not loaded by Pi" >&2; exit 1)
    echo "$PI_LOGS" | grep -q "CUSTOM_ENTRYPOINT_TS_LOADED:777" || (echo "Error: entrypoint TS extension was not loaded by Pi" >&2; exit 1)

    if echo "$PI_LOGS" | grep -q "DISABLED_EXT_LOADED"; then
      echo "Error: disabled extension was loaded by Pi" >&2
      exit 1
    fi

    # 6. Verify mutable state: Ensure auth.json and config were created in writable location
    test -d "$XDG_DATA_HOME/nixpi/agent"
    test -f "$XDG_DATA_HOME/nixpi/agent/settings.json"

    # 7. Verify settings.json contains custom skill, prompt, and theme
    grep -q "e2e-skill" "$XDG_DATA_HOME/nixpi/agent/settings.json"
    grep -q "e2e-prompt" "$XDG_DATA_HOME/nixpi/agent/settings.json"
    grep -q "custom-e2e-theme" "$XDG_DATA_HOME/nixpi/agent/settings.json"

    echo "E2E verification passed successfully" > "$out"
  ''
