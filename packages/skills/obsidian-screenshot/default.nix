{
  pkgs,
  mkPiSkill ? (pkgs.callPackage ../../../lib/mk-resource.nix { }).mkPiSkill,
}:

mkPiSkill {
  name = "obsidian-screenshot";
  description = "Capture native in-app Obsidian screenshots without OS screen recording permissions.";
  content = builtins.readFile ./SKILL.md;
  meta = {
    description = "Pi skill for taking internal Obsidian screenshots";
  };
}
