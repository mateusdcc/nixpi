{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.pi.skills.mermaid-diagrams;
  defaultPkg = pkgs.callPackage ../../packages/skills/mermaid-diagrams {
    mkPiSkill = (pkgs.callPackage ../../lib/mk-resource.nix { }).mkPiSkill;
  };
in
{
  options.programs.pi.skills.mermaid-diagrams = {
    enable = lib.mkEnableOption "Pi Mermaid diagram architecture and subagent validation skill";
    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPkg;
      description = "Package providing the mermaid-diagrams skill.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.pi.runtimePackages = [
      pkgs.mermaid-cli
    ];
  };
}
