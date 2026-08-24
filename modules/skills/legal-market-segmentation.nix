{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.pi.skills.legal-market-segmentation;
  defaultPkg = pkgs.callPackage ../../packages/skills/legal-market-segmentation {
    mkPiSkill = (pkgs.callPackage ../../lib/mk-resource.nix { }).mkPiSkill;
  };
in
{
  options.programs.pi.skills.legal-market-segmentation = {
    enable = lib.mkEnableOption "Pi legal market segmentation skill";
    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPkg;
      description = "Package providing the legal-market-segmentation skill.";
    };
  };
}
