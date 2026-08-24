{
  lib,
  pkgs,
  ...
}:

let
  promptPkg = pkgs.callPackage ../../packages/prompts/research-lawyer-opportunities { };
  ledgerPkg = pkgs.callPackage ../../packages/evidence-ledger { };
in
{
  programs.pi = {
    enable = lib.mkDefault true;

    settings = {
      defaultThinkingLevel = lib.mkDefault "high";
    };

    extensions = {
      research-tools.enable = lib.mkDefault true;
      ripgrep-search.enable = lib.mkDefault true;
      echo.enable = lib.mkDefault true;
    };

    skills = {
      legal-pain-discovery.enable = lib.mkDefault true;
      voice-of-customer-mining.enable = lib.mkDefault true;
      evidence-deduplication.enable = lib.mkDefault true;
      legal-market-segmentation.enable = lib.mkDefault true;
      competitor-gap-analysis.enable = lib.mkDefault true;
      brazil-localization-test.enable = lib.mkDefault true;
      opportunity-scoring.enable = lib.mkDefault true;
      product-opportunity-report.enable = lib.mkDefault true;
      commit-style.enable = lib.mkDefault true;
    };

    prompts = [ promptPkg ];
    packages = [ ledgerPkg ];

    runtimePackages = with pkgs; [
      duckdb
      python3
      nodejs
      curl
      jq
      ripgrep
    ];
  };
}
