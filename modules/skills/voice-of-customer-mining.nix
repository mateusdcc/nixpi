{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.pi.skills.voice-of-customer-mining;
  defaultPkg = pkgs.callPackage ../../packages/skills/voice-of-customer-mining {
    mkPiSkill = (pkgs.callPackage ../../lib/mk-resource.nix { }).mkPiSkill;
  };
in
{
  options.programs.pi.skills.voice-of-customer-mining = {
    enable = lib.mkEnableOption "Pi voice of customer mining skill";
    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPkg;
      description = "Package providing the voice-of-customer-mining skill.";
    };
  };
}
