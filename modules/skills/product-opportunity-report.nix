{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.pi.skills.product-opportunity-report;
  defaultPkg = pkgs.callPackage ../../packages/skills/product-opportunity-report {
    mkPiSkill = (pkgs.callPackage ../../lib/mk-resource.nix { }).mkPiSkill;
  };
in
{
  options.programs.pi.skills.product-opportunity-report = {
    enable = lib.mkEnableOption "Pi product opportunity report skill";
    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPkg;
      description = "Package providing the product-opportunity-report skill.";
    };
  };
}
