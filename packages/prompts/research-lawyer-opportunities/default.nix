{
  pkgs,
  mkPiPrompt ? (pkgs.callPackage ../../../lib/mk-resource.nix { }).mkPiPrompt,
}:

mkPiPrompt {
  name = "research-lawyer-opportunities";
  description = "Orchestrates multi-country legal practitioner pain point research and generates a ranked Brazil-localization product opportunity report";
  argumentHint = "[optional target segment or practice area]";
  content = builtins.readFile ../research-lawyer-opportunities.md;
}
