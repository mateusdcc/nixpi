{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.pi.skills.legal-pain-discovery;
  defaultPkg = pkgs.callPackage ../../packages/skills/legal-pain-discovery {
    mkPiSkill = (pkgs.callPackage ../../lib/mk-resource.nix { }).mkPiSkill;
  };
in
{
  options.programs.pi.skills.legal-pain-discovery = {
    enable = lib.mkEnableOption "Pi legal pain discovery research skill";
    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPkg;
      description = "Package providing the legal-pain-discovery skill.";
    };
  };
}
