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
  name = "evidence-deduplication";
  description = "Pi evidence deduplication skill";
  defaultPackage =
    pkgs:
    pkgs.callPackage ../../packages/skills/evidence-deduplication {
      mkPiSkill = (pkgs.callPackage ../../lib/mk-resource.nix { }).mkPiSkill;
    };
} { inherit config lib pkgs; }
