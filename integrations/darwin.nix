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
    environment.systemPackages = [
      cfg.finalPackage
    ];

    environment.variables = lib.filterAttrs (n: v: v != null) (
      builtins.mapAttrs (n: v: toString v) cfg.environment.variables
    );
  };
}
