{ pkgs, ... }:

{
  programs.pi = {
    enable = true;

    settings = {
      defaultProvider = "openai";
      defaultModel = "gpt-4o";
      defaultThinkingLevel = "medium";
      theme = "dark";
      compaction = {
        enabled = true;
        reserveTokens = 16384;
      };
    };

    extensions = {
      echo.enable = true;
      ripgrep-search.enable = true;
      plan-mode = {
        enable = true;
        mode = "balanced";
        maxSteps = 15;
      };
    };

    runtimePackages = with pkgs; [
      git
      ripgrep
      jq
      fd
    ];

    environment = {
      required = [
        "OPENAI_API_KEY"
      ];
    };
  };
}
