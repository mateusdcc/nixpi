{
  pkgs,
  self,
  system,
}:

let
  configuration = self.inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [
      self.homeModules.default
      {
        home = {
          username = "nixpi-test";
          homeDirectory = "/invalid/nixpi-test-home";
          stateVersion = "26.05";
        };
        programs.pi = {
          enable = true;
          settings.defaultProvider = "openai";
          environment.variables.PI_HOME_MANAGER_TEST = "enabled";
          extensions.echo.enable = true;
          providers.custom = {
            baseUrl = "http://localhost:8080";
            models = [ { id = "integration-model"; } ];
          };
        };
      }
    ];
  };

  cfg = configuration.config;
  allPass =
    pkgs.stdenv.hostPlatform.system == system
    && cfg.home.file ? ".pi/agent/settings.json"
    && cfg.home.file ? ".pi/agent/models.json"
    && builtins.elem cfg.programs.pi.finalPackage cfg.home.packages
    && cfg.home.sessionVariables.PI_HOME_MANAGER_TEST == "enabled";
in
pkgs.runCommand "nixpi-home-manager-integration-test" { } ''
  ${pkgs.lib.optionalString (!allPass) "echo 'Home Manager integration test failed' >&2; exit 1"}
  echo "Home Manager integration test passed" > "$out"
''
