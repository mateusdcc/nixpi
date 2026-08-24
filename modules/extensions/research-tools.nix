{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.pi.extensions.research-tools;
  researchToolsPkg = pkgs.callPackage ../../packages/extensions/research-tools {
    mkPiExtension = pkgs.callPackage ../../lib/mk-extension.nix { };
  };
in
{
  options.programs.pi.extensions.research-tools = {
    enable = lib.mkEnableOption "Pi legal tech research tools & MCP bridge extension";

    package = lib.mkOption {
      type = lib.types.package;
      default = researchToolsPkg;
      defaultText = lib.literalExpression "pkgs.piExtensions.research-tools";
      description = "Package providing the research-tools extension.";
    };

    enableWorldMonitor = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable World Monitor macro context tool (conditional, disabled by default).";
    };

    enableXhs = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable XHS / RedNote Chinese market research tool (conditional, disabled by default).";
    };

    enableGptResearcher = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable GPT Researcher synthesis fallback tool (conditional, disabled by default).";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.pi.environment.optional = [
      "BIGIDEASDB_API_KEY"
      "EXA_API_KEY"
      "FIRECRAWL_API_KEY"
      "APIFY_TOKEN"
      "APIFY_API_TOKEN"
      "WORLD_MONITOR_API_URL"
      "XHS_API_URL"
      "GPTR_MCP_URL"
    ];
  };
}
