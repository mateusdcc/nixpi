{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.pi.skills.competitor-gap-analysis;
  defaultPkg = pkgs.callPackage ../../packages/skills/competitor-gap-analysis {
    mkPiSkill = (pkgs.callPackage ../../lib/mk-resource.nix { }).mkPiSkill;
  };
in
{
  options.programs.pi.skills.competitor-gap-analysis = {
    enable = lib.mkEnableOption "Pi competitor gap analysis skill";
    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPkg;
      description = "Package providing the competitor-gap-analysis skill.";
    };
  };
}
