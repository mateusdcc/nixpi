{ pkgs }:

let
  lib = pkgs.lib;

  # Minimal mock of Home Manager module options
  mockHomeManagerModule = {
    options.home = {
      packages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
      };
      file = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options.source = lib.mkOption {
              type = lib.types.package;
            };
          }
        );
        default = { };
      };
      sessionVariables = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
      };
    };
  };

  evaluated = lib.evalModules {
    modules = [
      mockHomeManagerModule
      ../../integrations/home-manager.nix
      {
        programs.pi = {
          enable = true;
          settings.defaultProvider = "openai";
          environment.variables.PI_CUSTOM_VAR = "1";
          extensions.echo.enable = true;
          providers.custom = {
            baseUrl = "http://localhost:8080";
            models = [ { id = "m1"; } ];
          };
        };
      }
    ];
    specialArgs = {
      inherit pkgs;
    };
  };

  cfg = evaluated.config;
  hasSettingsFile = cfg.home.file ? ".pi/agent/settings.json";
  hasModelsFile = cfg.home.file ? ".pi/agent/models.json";
  hasPackage = lib.length cfg.home.packages > 0;
  hasEnvVar = cfg.home.sessionVariables.PI_CUSTOM_VAR == "1";

  allPass = hasSettingsFile && hasModelsFile && hasPackage && hasEnvVar;
in
pkgs.runCommand "nixpi-hm-test" { } ''
  ${lib.optionalString (!allPass) "echo 'Home Manager integration test failed' >&2; exit 1"}
  echo "Home Manager integration test passed" > "$out"
''
