{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.pi.skills.literature-deep-dive;
  defaultPkg = pkgs.callPackage ../../packages/skills/literature-deep-dive {
    mkPiSkill = (pkgs.callPackage ../../lib/mk-resource.nix { }).mkPiSkill;
  };
in
{
  options.programs.pi.skills.literature-deep-dive = {
    enable = lib.mkEnableOption "Pi literature and research paper deep-dive skill";
    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPkg;
      description = "Package providing the literature-deep-dive skill.";
    };
  };
}
