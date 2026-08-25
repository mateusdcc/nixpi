{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.pi.skills.feynman-technique;
  defaultPkg = pkgs.callPackage ../../packages/skills/feynman-technique {
    mkPiSkill = (pkgs.callPackage ../../lib/mk-resource.nix { }).mkPiSkill;
  };
in
{
  options.programs.pi.skills.feynman-technique = {
    enable = lib.mkEnableOption "Pi Feynman technique learning skill";
    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPkg;
      description = "Package providing the feynman-technique skill.";
    };
  };
}
