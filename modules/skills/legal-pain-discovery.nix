{
  config,
  lib,
  pkgs,
  ...
}:

let
  factories = import ../../lib/module-factories.nix { inherit lib; };
in
factories.mkPiSkillModule {
  name = "legal-pain-discovery";
  description = "Pi legal pain discovery research skill";
  defaultPackage =
    pkgs:
    pkgs.callPackage ../../packages/skills/legal-pain-discovery {
      mkPiSkill = (pkgs.callPackage ../../lib/mk-resource.nix { }).mkPiSkill;
    };
} { inherit config lib pkgs; }
