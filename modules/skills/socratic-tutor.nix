{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.pi.skills.socratic-tutor;
  defaultPkg = pkgs.callPackage ../../packages/skills/socratic-tutor {
    mkPiSkill = (pkgs.callPackage ../../lib/mk-resource.nix { }).mkPiSkill;
  };
in
{
  options.programs.pi.skills.socratic-tutor = {
    enable = lib.mkEnableOption "Pi Socratic tutor learning skill";
    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPkg;
      description = "Package providing the socratic-tutor skill.";
    };
  };
}
