{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.pi.skills.active-recall-notes;
  defaultPkg = pkgs.callPackage ../../packages/skills/active-recall-notes {
    mkPiSkill = (pkgs.callPackage ../../lib/mk-resource.nix { }).mkPiSkill;
  };
in
{
  options.programs.pi.skills.active-recall-notes = {
    enable = lib.mkEnableOption "Pi active recall and Obsidian note synthesis skill";
    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPkg;
      description = "Package providing the active-recall-notes skill.";
    };
  };
}
