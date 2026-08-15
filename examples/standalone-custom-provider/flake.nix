{
  description = "Example: Custom provider (e.g. Antigravity) configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpi.url = "github:mateusdcc/nixpi";
  };

  outputs =
    { nixpkgs, nixpi, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = nixpi.lib.makePi {
        inherit pkgs;
        modules = [
          (
            { config, ... }:
            {
              programs.pi = {
                enable = true;

                # Enable Antigravity provider package (OAuth login + Google models)
                providers.antigravity.enable = true;

                # Custom static provider constructed with mkPiProvider
                providers.local-llm = nixpi.lib.mkPiProvider {
                  name = "local-llm";
                  baseUrl = "http://127.0.0.1:11434/v1";
                  api = "openai-completions";
                  models = [
                    {
                      id = "qwen2.5-coder";
                      name = "Qwen 2.5 Coder";
                      contextWindow = 32768;
                    }
                  ];
                };

                settings = {
                  # Reference provider and model objects directly
                  defaultProvider = config.programs.pi.providers.antigravity;
                  defaultModel = config.programs.pi.providers.antigravity.models."gemini-3.7-flash";
                  defaultThinkingLevel = "high";
                  theme = "dark";
                };

                # Declare non-secret env vars
                environment.variables = {
                  PI_OFFLINE = "0";
                };
              };
            }
          )
        ];
      };
    };
}
