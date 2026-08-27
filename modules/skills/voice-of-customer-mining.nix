args@{ lib, ... }:

let
  factories = import ../../lib/module-factories.nix { inherit lib; };
in
factories.mkPiSkillModule {
  name = "voice-of-customer-mining";
  description = "Pi voice of customer mining skill";
  defaultPackage =
    pkgs:
    pkgs.callPackage ../../packages/skills/voice-of-customer-mining {
      mkPiSkill = (pkgs.callPackage ../../lib/mk-resource.nix { }).mkPiSkill;
    };
} args
