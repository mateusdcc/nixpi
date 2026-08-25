{
  lib,
  pkgs,
  ...
}:

{
  programs.pi = {
    enable = lib.mkDefault true;

    settings = {
      defaultThinkingLevel = lib.mkDefault "high";
    };

    extensions = {
      obsidian.enable = lib.mkDefault true;
      ripgrep-search.enable = lib.mkDefault true;
      pi-gpt-search.enable = lib.mkDefault true;
      plan-mode.enable = lib.mkDefault true;
      echo.enable = lib.mkDefault true;
    };

    skills = {
      obsidian-screenshot.enable = lib.mkDefault true;
      socratic-tutor.enable = lib.mkDefault true;
      feynman-technique.enable = lib.mkDefault true;
      active-recall-notes.enable = lib.mkDefault true;
      literature-deep-dive.enable = lib.mkDefault true;
      commit-style.enable = lib.mkDefault true;
    };

    runtimePackages = with pkgs; [
      glow
      ripgrep
      jq
      curl
      python3
    ];
  };
}
