{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.pi.skills.brazil-localization-test;
  defaultPkg = pkgs.callPackage ../../packages/skills/brazil-localization-test {
    mkPiSkill = (pkgs.callPackage ../../lib/mk-resource.nix { }).mkPiSkill;
  };
in
{
  options.programs.pi.skills.brazil-localization-test = {
    enable = lib.mkEnableOption "Pi Brazil localization test skill";
    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPkg;
      description = "Package providing the brazil-localization-test skill.";
    };
  };
}
