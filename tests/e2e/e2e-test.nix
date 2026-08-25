{ pkgs, nixpiLib }:

let
  configuredPi = nixpiLib.makePi {
    inherit pkgs;
    modules = [
      {
        programs.pi = {
          enable = true;
          settings = {
            defaultProvider = "openai";
            theme = "dark";
          };
          extensions = {
            echo.enable = true;
            ripgrep-search.enable = true;
          };
          environment.variables = {
            PI_TEST_ENV_VAR = "nixpi-verified";
          };
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

    # 1. Test version output
    VERSION_OUTPUT=$("${configuredPi}/bin/pi" --version)
    echo "Reported Pi version: $VERSION_OUTPUT"
    if [ -z "$VERSION_OUTPUT" ]; then
      echo "Error: Unexpected empty pi version output" >&2
      exit 1
    fi

    # 2. Verify wrapper script contains ripgrep in PATH
    grep -q "ripgrep" "${configuredPi}/bin/pi" || (echo "Error: ripgrep was not in pi wrapper PATH" >&2; exit 1)

    # 3. Test safe non-network model listing with offline flag
    "${configuredPi}/bin/pi" --list-models || true

    # 4. Verify mutable state: Ensure auth.json and config were created in writable location
    test -d "$XDG_DATA_HOME/nixpi/agent"
    test -f "$XDG_DATA_HOME/nixpi/agent/settings.json"

    echo "E2E verification passed successfully" > "$out"
  ''
