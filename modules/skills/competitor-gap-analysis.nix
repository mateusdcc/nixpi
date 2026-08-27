args@{ lib, ... }:

let
  factories = import ../../lib/module-factories.nix { inherit lib; };
in
factories.mkPiSkillModule {
  name = "competitor-gap-analysis";
  description = "Pi competitor gap analysis skill";
  defaultPackage =
    pkgs:
    pkgs.callPackage ../../packages/skills/competitor-gap-analysis {
      mkPiSkill = (pkgs.callPackage ../../lib/mk-resource.nix { }).mkPiSkill;
    };
} args
