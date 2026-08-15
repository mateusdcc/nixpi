{ config, lib, ... }:

let
  extractProviderName =
    p:
    if builtins.isString p then
      p
    else if builtins.isAttrs p then
      p.name or p.id or p.passthru.providerName or p.passthru.name or p.pname
        or (throw "Invalid provider object: missing name or id")
    else
      throw "Invalid defaultProvider value: expected string or provider object";

  extractModelId =
    m:
    if builtins.isString m then
      m
    else if builtins.isAttrs m then
      m.id or m.name or m.passthru.modelId or (throw "Invalid model object: missing id or name")
    else
      throw "Invalid defaultModel value: expected string or model object";

  defaultProviderType = lib.types.coercedTo (lib.types.oneOf [
    lib.types.str
    lib.types.attrs
  ]) extractProviderName (lib.types.nullOr lib.types.str);

  defaultModelType = lib.types.coercedTo (lib.types.oneOf [
    lib.types.str
    lib.types.attrs
  ]) extractModelId (lib.types.nullOr lib.types.str);

  compactionType = lib.types.submodule {
    options = {
      enabled = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Enable auto-compaction.";
      };
      reserveTokens = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Tokens reserved for LLM response.";
      };
      keepRecentTokens = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Recent tokens to keep without summarization.";
      };
    };
  };

  retryProviderType = lib.types.submodule {
    options = {
      timeoutMs = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Provider timeout in milliseconds.";
      };
      maxRetries = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Provider/SDK retry attempts.";
      };
      maxRetryDelayMs = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Max server-requested delay before failing.";
      };
    };
  };

  retryType = lib.types.submodule {
    options = {
      enabled = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Enable automatic agent-level retry.";
      };
      maxRetries = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Maximum agent-level retry attempts.";
      };
      baseDelayMs = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Base delay for exponential backoff.";
      };
      provider = lib.mkOption {
        type = lib.types.nullOr retryProviderType;
        default = null;
        description = "Provider-level retry configuration.";
      };
    };
  };

  cfg = config.programs.pi;
  availableProviders = lib.unique (
    (cfg.builtinProviders or [ ]) ++ (builtins.attrNames (cfg.providers or { }))
  );
in

{
  options.programs.pi.settings = lib.mkOption {
    type = lib.types.submodule {
      freeformType = lib.types.attrsOf lib.types.anything;

      options = {
        defaultProvider = lib.mkOption {
          type = defaultProviderType;
          default = null;
          description = "Default LLM provider to use (string name or provider object).";
        };

        defaultModel = lib.mkOption {
          type = defaultModelType;
          default = null;
          description = "Default model ID to use (string ID or model object).";
        };

        defaultThinkingLevel = lib.mkOption {
          type = lib.types.nullOr (
            lib.types.enum [
              "off"
              "minimal"
              "low"
              "medium"
              "high"
              "xhigh"
              "max"
            ]
          );
          default = null;
          description = "Default reasoning/thinking level.";
        };

        theme = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Name of the active theme.";
        };

        enabledModels = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Model patterns for Ctrl+P cycling.";
        };

        compaction = lib.mkOption {
          type = lib.types.nullOr compactionType;
          default = null;
          description = "Conversation compaction settings.";
        };

        retry = lib.mkOption {
          type = lib.types.nullOr retryType;
          default = null;
          description = "Agent and provider retry settings.";
        };

        npmCommand = lib.mkOption {
          type = lib.types.nullOr (lib.types.listOf lib.types.str);
          default = null;
          description = "Command argv used for npm package operations.";
        };

        sessionDir = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Directory for session storage and lookup.";
        };

        enableSkillCommands = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Register skills as /skill:name commands.";
        };
      };
    };
    default = { };
    description = "Pi settings configuration (generated as settings.json).";
  };

  config = lib.mkIf (cfg.settings.defaultProvider != null) {
    programs.pi.assertions = [
      {
        assertion = builtins.elem cfg.settings.defaultProvider availableProviders;
        message = "nixpi: programs.pi.settings.defaultProvider '${toString cfg.settings.defaultProvider}' is not a recognized built-in provider or declared custom provider. Available providers: ${lib.concatStringsSep ", " availableProviders}";
      }
    ];
  };
}
