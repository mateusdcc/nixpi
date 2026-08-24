{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.pi.skills.opportunity-scoring;
  defaultPkg = pkgs.callPackage ../../packages/skills/opportunity-scoring {
    mkPiSkill = (pkgs.callPackage ../../lib/mk-resource.nix { }).mkPiSkill;
  };
in
{
  options.programs.pi.skills.opportunity-scoring = {
    enable = lib.mkEnableOption "Pi opportunity scoring skill";
    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPkg;
      description = "Package providing the opportunity-scoring skill.";
    };
  };
}
