{
  pkgs,
  self,
  system,
}:

let
  configuration = self.inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.default
      {
        nixpkgs.hostPlatform = system;
        system.stateVersion = "26.05";
        boot.loader.systemd-boot.enable = true;
        fileSystems."/" = {
          fsType = "none";
          device = "/non-existent/nixpi-test-device";
        };
        programs.pi = {
          enable = true;
          settings.defaultProvider = "openai";
          environment.variables.PI_NIXOS_TEST = "enabled";
          extensions.echo.enable = true;
        };
      }
    ];
  };

  cfg = configuration.config;
  allPass =
    cfg.nixpkgs.hostPlatform.system == system
    && builtins.elem cfg.programs.pi.finalPackage cfg.environment.systemPackages
    && cfg.environment.sessionVariables.PI_NIXOS_TEST == "enabled";
in
pkgs.runCommand "nixpi-nixos-integration-test" { } ''
  ${pkgs.lib.optionalString (!allPass) "echo 'NixOS integration test failed' >&2; exit 1"}
  echo "NixOS integration test passed" > "$out"
''
