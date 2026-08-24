{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.pi.skills.evidence-deduplication;
  defaultPkg = pkgs.callPackage ../../packages/skills/evidence-deduplication {
    mkPiSkill = (pkgs.callPackage ../../lib/mk-resource.nix { }).mkPiSkill;
  };
in
{
  options.programs.pi.skills.evidence-deduplication = {
    enable = lib.mkEnableOption "Pi evidence deduplication skill";
    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPkg;
      description = "Package providing the evidence-deduplication skill.";
    };
  };
}
