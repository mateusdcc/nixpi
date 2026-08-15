{ lib, ... }:

let
  modelType = lib.types.submodule {
    freeformType = lib.types.attrsOf lib.types.anything;

    options = {
      id = lib.mkOption {
        type = lib.types.str;
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
  };

  providerType = lib.types.submodule {
    freeformType = lib.types.attrsOf lib.types.anything;

    options = {
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
        description = "API key or placeholder. For secret tokens, use environment variables instead of hardcoding.";
      };

      models = lib.mkOption {
        type = lib.types.listOf modelType;
        default = [ ];
        description = "List of models offered by this provider.";
      };
    };
  };
in
{
  options.programs.pi.providers = lib.mkOption {
    type = lib.types.attrsOf providerType;
    default = { };
    description = "Custom and overridden LLM providers (generated into models.json).";
  };
}
