{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.pi.extensions.pi-gpt-search;
  piGptSearchPkg = pkgs.callPackage ../../packages/extensions/pi-gpt-search {
    mkPiExtension = pkgs.callPackage ../../lib/mk-extension.nix { };
  };
in
{
  options.programs.pi.extensions.pi-gpt-search = {
    enable = lib.mkEnableOption "Pi GPT search extension (OpenAI Codex search engine)";

    package = lib.mkOption {
      type = lib.types.package;
      default = piGptSearchPkg;
      defaultText = lib.literalExpression "pkgs.piExtensions.pi-gpt-search";
      description = "Package providing the pi-gpt-search extension.";
    };

    debug = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable debug logging for web search operations.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.pi.environment.optional = [
      "CODEX_ACCESS_TOKEN"
      "CODEX_ACCOUNT_ID"
      "PI_WEB_SEARCH_DEBUG"
    ];

    programs.pi.environment.variables = lib.mkIf cfg.debug {
      PI_WEB_SEARCH_DEBUG = "1";
    };
  };
}
