{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.pi.skills.deep-comprehension-engine;
  defaultPkg = pkgs.callPackage ../../packages/skills/deep-comprehension-engine {
    mkPiSkill = (pkgs.callPackage ../../lib/mk-resource.nix { }).mkPiSkill;
  };
in
{
  options.programs.pi.skills.deep-comprehension-engine = {
    enable = lib.mkEnableOption "Pi deep comprehension engine master learning skill";
    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPkg;
      description = "Package providing the deep-comprehension-engine skill.";
    };
  };
}
