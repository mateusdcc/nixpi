{ lib, ... }:

{
  programs.pi = {
    enable = lib.mkDefault true;
    settings = {
      defaultThinkingLevel = lib.mkDefault "medium";
      compaction = {
        enabled = lib.mkDefault true;
        reserveTokens = lib.mkDefault 16384;
      };
    };
  };
}
