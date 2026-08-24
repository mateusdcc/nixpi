{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.pi.skills.obsidian-screenshot;
  defaultObsidianScreenshotPkg = pkgs.callPackage ../../packages/skills/obsidian-screenshot {
    mkPiSkill = (pkgs.callPackage ../../lib/mk-resource.nix { }).mkPiSkill;
  };
in
{
  options.programs.pi.skills.obsidian-screenshot = {
    enable = lib.mkEnableOption "Pi Obsidian screenshot skill (in-app capture without OS permissions)";

    package = lib.mkOption {
      type = lib.types.package;
      default = defaultObsidianScreenshotPkg;
      defaultText = lib.literalExpression "pkgs.piSkills.obsidian-screenshot";
      description = "Package providing the obsidian-screenshot skill.";
    };
  };
}
