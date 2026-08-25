{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.pi.skills.paginated-atomic-notes;
  defaultPkg = pkgs.callPackage ../../packages/skills/paginated-atomic-notes {
    mkPiSkill = (pkgs.callPackage ../../lib/mk-resource.nix { }).mkPiSkill;
  };
in
{
  options.programs.pi.skills.paginated-atomic-notes = {
    enable = lib.mkEnableOption "Pi paginated atomic notes authoring skill with in-note quizzes";
    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPkg;
      description = "Package providing the paginated-atomic-notes skill.";
    };
  };
}
