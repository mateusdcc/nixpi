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
  name = "legal-market-segmentation";
  description = "Pi legal market segmentation skill";
  defaultPackage =
    pkgs:
    pkgs.callPackage ../../packages/skills/legal-market-segmentation {
      mkPiSkill = (pkgs.callPackage ../../lib/mk-resource.nix { }).mkPiSkill;
    };
} { inherit config lib pkgs; }
