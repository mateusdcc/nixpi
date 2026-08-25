{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.pi.skills.gifted-diagnostic-probe;
  defaultPkg = pkgs.callPackage ../../packages/skills/gifted-diagnostic-probe {
    mkPiSkill = (pkgs.callPackage ../../lib/mk-resource.nix { }).mkPiSkill;
  };
in
{
  options.programs.pi.skills.gifted-diagnostic-probe = {
    enable = lib.mkEnableOption "Pi 3-tier gifted diagnostic knowledge probing skill";
    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPkg;
      description = "Package providing the gifted-diagnostic-probe skill.";
    };
  };
}
