{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.pi.extensions.obsidian;
  obsidianPkg = pkgs.callPackage ../../packages/extensions/obsidian {
    mkPiExtension = pkgs.callPackage ../../lib/mk-extension.nix { };
  };
in
{
  options.programs.pi.extensions.obsidian = {
    enable = lib.mkEnableOption "Pi Obsidian integration extension";

    package = lib.mkOption {
      type = lib.types.package;
      default = obsidianPkg;
      defaultText = lib.literalExpression "pkgs.piExtensions.obsidian";
      description = "Package providing the Obsidian extension.";
    };

    vaultPath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Default filesystem path to the Obsidian vault directory.";
    };

    apiUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://127.0.0.1:27124";
      description = "Obsidian Local REST API base URL.";
    };

    apiKey = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Obsidian Local REST API secret key (prefer passing via OBSIDIAN_API_KEY env var for secret safety).";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.pi.runtimePackages = [
      pkgs.curl
      pkgs.jq
    ];

    programs.pi.environment.variables = {
      OBSIDIAN_REST_API_URL = cfg.apiUrl;
    }
    // lib.optionalAttrs (cfg.vaultPath != null) {
      OBSIDIAN_VAULT_PATH = cfg.vaultPath;
    }
    // lib.optionalAttrs (cfg.apiKey != null) {
      OBSIDIAN_API_KEY = cfg.apiKey;
    };
  };
}
