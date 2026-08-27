{
  pkgs,
  self,
  system,
}:

let
  configuration = self.inputs.nix-darwin.lib.darwinSystem {
    modules = [
      self.nixDarwinModules.default
      {
        nixpkgs.hostPlatform = system;
        system.stateVersion = 6;
        programs.pi = {
          enable = true;
          settings.defaultProvider = "anthropic";
          environment.variables.PI_DARWIN_TEST = "enabled";
          extensions.echo.enable = true;
        };
      }
    ];
  };

  cfg = configuration.config;
  allPass =
    cfg.nixpkgs.hostPlatform.system == system
    && builtins.elem cfg.programs.pi.finalPackage cfg.environment.systemPackages
    && cfg.environment.variables.PI_DARWIN_TEST == "enabled";
in
pkgs.runCommand "nixpi-darwin-integration-test" { } ''
  ${pkgs.lib.optionalString (!allPass) "echo 'nix-darwin integration test failed' >&2; exit 1"}
  echo "nix-darwin integration test passed" > "$out"
''
