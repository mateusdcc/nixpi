{ lib, pkgs, ... }:

let
  modelType = lib.types.submodule (
    { name, ... }:
    {
      freeformType = lib.types.attrsOf lib.types.anything;

      options = {
        id = lib.mkOption {
          type = lib.types.str;
          default = name;
          description = "Unique model identifier.";
        };

        name = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Human-readable display name for the model.";
        };

        reasoning = lib.mkOption {
          type = lib.types.nullOr lib.types.bool;
          default = null;
          description = "Whether the model supports extended reasoning/thinking.";
        };

        contextWindow = lib.mkOption {
          type = lib.types.nullOr lib.types.int;
          default = null;
          description = "Maximum context window size in tokens.";
        };

        maxTokens = lib.mkOption {
          type = lib.types.nullOr lib.types.int;
          default = null;
          description = "Maximum output tokens.";
        };
      };
    }
  );

  modelsType = lib.types.coercedTo (lib.types.listOf lib.types.anything) (
    list:
    builtins.listToAttrs (
      map (
        m:
        if builtins.isString m then
          {
            name = m;
            value = {
              id = m;
            };
          }
        else
          {
            name = m.id or m.name;
            value = m;
          }
      ) list
    )
  ) (lib.types.attrsOf modelType);

  environmentType = lib.types.submodule {
    options = {
      variables = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = { };
        description = "Environment variables exported for this provider.";
      };

      required = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Required environment variable names.";
      };

      optional = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Optional environment variable names.";
      };
    };
  };

  antigravityDefaultPkg = pkgs.callPackage ../../packages/providers/antigravity {
    mkPiExtension = pkgs.callPackage ../../lib/mk-extension.nix { };
  };

  defaultProviders = {
    antigravity = {
      name = "antigravity";
      enable = false;
      models = {
        "gemini-3.7-flash" = {
          id = "gemini-3.7-flash";
          name = "Gemini 3.7 Flash";
          reasoning = true;
        };
        "gemini-3.1-pro" = {
          id = "gemini-3.1-pro";
          name = "Gemini 3.1 Pro";
          reasoning = true;
        };
        "claude-sonnet-4-6" = {
          id = "claude-sonnet-4-6";
          name = "Claude Sonnet 4.6";
          reasoning = true;
        };
        "claude-opus-4-6" = {
          id = "claude-opus-4-6";
          name = "Claude Opus 4.6";
          reasoning = true;
        };
      };
    };
    openai = {
      name = "openai";
      enable = true;
      models = {
        "gpt-4o" = {
          id = "gpt-4o";
          name = "GPT-4o";
        };
        "gpt-4o-mini" = {
          id = "gpt-4o-mini";
          name = "GPT-4o Mini";
        };
        "o1" = {
          id = "o1";
          name = "o1";
          reasoning = true;
        };
        "o3-mini" = {
          id = "o3-mini";
          name = "o3-mini";
          reasoning = true;
        };
      };
    };
    anthropic = {
      name = "anthropic";
      enable = true;
      models = {
        "claude-3-7-sonnet" = {
          id = "claude-3-7-sonnet";
          name = "Claude 3.7 Sonnet";
          reasoning = true;
        };
        "claude-3-5-sonnet" = {
          id = "claude-3-5-sonnet";
          name = "Claude 3.5 Sonnet";
        };
        "claude-3-5-haiku" = {
          id = "claude-3-5-haiku";
          name = "Claude 3.5 Haiku";
        };
      };
    };
    google = {
      name = "google";
      enable = true;
      models = {
        "gemini-2.5-pro" = {
          id = "gemini-2.5-pro";
          name = "Gemini 2.5 Pro";
          reasoning = true;
        };
        "gemini-2.5-flash" = {
          id = "gemini-2.5-flash";
          name = "Gemini 2.5 Flash";
          reasoning = true;
        };
        "gemini-2.0-flash" = {
          id = "gemini-2.0-flash";
          name = "Gemini 2.0 Flash";
        };
      };
    };
    ollama = {
      name = "ollama";
      enable = true;
      models = { };
    };
    openrouter = {
      name = "openrouter";
      enable = true;
      models = { };
    };
    groq = {
      name = "groq";
      enable = true;
      models = { };
    };
    deepseek = {
      name = "deepseek";
      enable = true;
      models = {
        "deepseek-chat" = {
          id = "deepseek-chat";
          name = "DeepSeek V3";
        };
        "deepseek-reasoner" = {
          id = "deepseek-reasoner";
          name = "DeepSeek R1";
          reasoning = true;
        };
      };
    };
    mistral = {
      name = "mistral";
      enable = true;
      models = { };
    };
    bedrock = {
      name = "bedrock";
      enable = true;
      models = { };
    };
    xai = {
      name = "xai";
      enable = true;
      models = {
        "grok-2" = {
          id = "grok-2";
          name = "Grok 2";
        };
      };
    };
    github-models = {
      name = "github-models";
      enable = true;
      models = { };
    };
    copilot = {
      name = "copilot";
      enable = true;
      models = { };
    };
    azure-openai = {
      name = "azure-openai";
      enable = true;
      models = { };
    };
    cerebras = {
      name = "cerebras";
      enable = true;
      models = { };
    };
    together = {
      name = "together";
      enable = true;
      models = { };
    };
    fireworks = {
      name = "fireworks";
      enable = true;
      models = { };
    };
    cohere = {
      name = "cohere";
      enable = true;
      models = { };
    };
  };

  defaultModelsFor =
    name:
    if defaultProviders ? ${name} && defaultProviders.${name} ? models then
      defaultProviders.${name}.models
    else
      { };

  providerType = lib.types.submodule (
    { name, ... }:
    {
      freeformType = lib.types.attrsOf lib.types.anything;

      options = {
        name = lib.mkOption {
          type = lib.types.str;
          default = name;
          description = "Provider identifier.";
        };

        enable = lib.mkOption {
          type = lib.types.bool;
          default = if defaultProviders ? ${name} then defaultProviders.${name}.enable or true else true;
          description = "Whether this provider is enabled.";
        };

        package = lib.mkOption {
          type = lib.types.nullOr lib.types.package;
          default = if name == "antigravity" then antigravityDefaultPkg else null;
          description = "Optional package/extension derivation implementing this provider.";
        };

        packages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          description = "Additional packages implementing this provider.";
        };

        baseUrl = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Base URL for the provider API endpoint.";
        };

        api = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "API protocol type (e.g. openai-completions, anthropic-messages).";
        };

        apiKey = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "API key or placeholder.";
        };

        models = lib.mkOption {
          type = modelsType;
          default = defaultModelsFor name;
          description = "Models offered by this provider.";
        };

        runtimePackages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          description = "Runtime dependencies added to PATH for this provider.";
        };

        environment = lib.mkOption {
          type = environmentType;
          default = { };
          description = "Environment variables and secret requirements for this provider.";
        };
      };
    }
  );

  builtinProvidersList = [
    "antigravity"
    "openai"
    "anthropic"
    "google"
    "ollama"
    "openrouter"
    "groq"
    "deepseek"
    "mistral"
    "bedrock"
    "xai"
    "github-models"
    "copilot"
    "azure-openai"
    "cerebras"
    "together"
    "fireworks"
    "cohere"
  ];
in
{
  options.programs.pi = {
    providers = lib.mkOption {
      type = lib.types.attrsOf providerType;
      default = { };
      description = "Declared LLM providers with options and model definitions.";
    };

    builtinProviders = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = builtinProvidersList;
      readOnly = true;
      description = "List of built-in LLM providers.";
    };
  };

  config.programs.pi.providers = lib.mapAttrs (n: prov: {
    name = lib.mkDefault prov.name;
    enable = lib.mkDefault (prov.enable or true);
    models = lib.mkDefault (prov.models or { });
  }) defaultProviders;
}
