args@{ lib, ... }:

let
  factories = import ../../lib/module-factories.nix { inherit lib; };
in
factories.mkPiSkillModule {
  name = "product-opportunity-report";
  description = "Pi product opportunity report skill";
  defaultPackage =
    pkgs:
    pkgs.callPackage ../../packages/skills/product-opportunity-report {
      mkPiSkill = (pkgs.callPackage ../../lib/mk-resource.nix { }).mkPiSkill;
    };
} args
