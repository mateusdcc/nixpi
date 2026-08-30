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
  name = "brazil-localization-test";
  description = "Pi Brazil localization test skill";
  defaultPackage =
    pkgs:
    pkgs.callPackage ../../packages/skills/brazil-localization-test {
      mkPiSkill = (pkgs.callPackage ../../lib/mk-resource.nix { }).mkPiSkill;
    };
} { inherit config lib pkgs; }
