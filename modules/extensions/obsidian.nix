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
  effectiveVault = if cfg.defaultVault != null then cfg.defaultVault else cfg.vaultPath;
  vaultInstructionSkill =
    if effectiveVault != null then
      pkgs.writeTextDir "skills/obsidian-default-vault/SKILL.md" ''
        ---
        name: obsidian-default-vault
        description: Directives for default Obsidian vault operations
        ---
        # Obsidian Default Vault Instructions

        The user's default Obsidian vault is configured at:
        `${effectiveVault}`

        ## Directives
        - NEVER ask the user which vault to use or where the vault is located.
        - Always use the default vault (`${effectiveVault}`) for all Obsidian operations (opening notes, searching notes, reading/modifying settings, link graph analysis, and plugin installation).
        - When referencing notes, resolve paths relative to this vault without prompting for confirmation.
      ''
    else
      null;
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

    defaultVault = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Default filesystem path to the Obsidian vault directory. When set, automatically injects instruction markdown so Pi never asks which vault to use.";
    };

    vaultPath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Alias for defaultVault.";
    };

    apiUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://127.0.0.1:27125";
      description = "Obsidian Bridge or Local REST API base URL.";
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

    programs.pi.rawSkills = lib.optional (vaultInstructionSkill != null) vaultInstructionSkill;

    programs.pi.environment.variables = {
      OBSIDIAN_REST_API_URL = cfg.apiUrl;
    }
    // lib.optionalAttrs (effectiveVault != null) {
      OBSIDIAN_DEFAULT_VAULT = effectiveVault;
      OBSIDIAN_VAULT_PATH = effectiveVault;
    }
    // lib.optionalAttrs (cfg.apiKey != null) {
      OBSIDIAN_API_KEY = cfg.apiKey;
    };
  };
}
