{ pkgs }:

let
  lib = pkgs.lib;

  # Minimal mock of NixOS module options
  mockNixOSModule = {
    options.environment = {
      systemPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
      };
      sessionVariables = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
      };
    };
  };

  evaluated = lib.evalModules {
    modules = [
      mockNixOSModule
      ../../integrations/nixos.nix
      {
        programs.pi = {
          enable = true;
          settings.defaultProvider = "openai";
          environment.variables.PI_NIXOS_FLAG = "enabled";
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
  hasEnvVar = cfg.environment.sessionVariables.PI_NIXOS_FLAG == "enabled";

  allPass = hasPackage && hasEnvVar;
in
pkgs.runCommand "nixpi-nixos-test" { } ''
  ${lib.optionalString (!allPass) "echo 'NixOS integration test failed' >&2; exit 1"}
  echo "NixOS integration test passed" > "$out"
''
