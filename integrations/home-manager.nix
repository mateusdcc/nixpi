{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.pi;
in
{
  imports = [
    ../modules
  ];

  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.finalPackage
    ];

    home.file = {
      ".pi/agent/settings.json".source = cfg.generatedSettingsFile;
    }
    // (lib.optionalAttrs (cfg.generatedModelsFile != null) {
      ".pi/agent/models.json".source = cfg.generatedModelsFile;
    });

    home.sessionVariables = lib.filterAttrs (n: v: v != null) (
      builtins.mapAttrs (n: v: toString v) cfg.environment.variables
    );
  };
}
