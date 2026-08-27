args@{ lib, ... }:

let
  factories = import ../../lib/module-factories.nix { inherit lib; };
in
factories.mkPiSkillModule {
  name = "opportunity-scoring";
  description = "Pi opportunity scoring skill";
  defaultPackage =
    pkgs:
    pkgs.callPackage ../../packages/skills/opportunity-scoring {
      mkPiSkill = (pkgs.callPackage ../../lib/mk-resource.nix { }).mkPiSkill;
    };
} args
