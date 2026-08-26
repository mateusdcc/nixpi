{ pkgs }:

let
  lib = pkgs.lib;

  # Minimal mock of nix-darwin module options
  mockDarwinModule = {
    options.environment = {
      systemPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
      };
      variables = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
      };
    };
  };

  evaluated = lib.evalModules {
    modules = [
      mockDarwinModule
      ../../integrations/darwin.nix
      {
        programs.pi = {
          enable = true;
          settings.defaultProvider = "anthropic";
          environment.variables.PI_DARWIN_FLAG = "enabled";
          extensions.echo.enable = true;
        };
      }
    ];
    specialArgs = {
      inherit pkgs;
    };
  };

  cfg = evaluated.config;
  hasPackage = lib.length cfg.environment.systemPackages > 0;
  hasEnvVar = cfg.environment.variables.PI_DARWIN_FLAG == "enabled";

  allPass = hasPackage && hasEnvVar;
in
pkgs.runCommand "nixpi-darwin-test" { } ''
  ${lib.optionalString (!allPass) "echo 'nix-darwin integration test failed' >&2; exit 1"}
  echo "nix-darwin integration test passed" > "$out"
''
