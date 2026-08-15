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
          {
            programs.pi = {
              enable = true;

              settings = {
                defaultProvider = "antigravity";
                defaultModel = "gemini-3.7-flash";
                defaultThinkingLevel = "high";
                theme = "dark";
              };

              # Custom provider configuration (generates models.json)
              providers.antigravity = {
                baseUrl = "https://api.antigravity.test/v1";
                api = "openai-completions";
                models = [
                  {
                    id = "gemini-3.7-flash";
                    name = "Antigravity 3.7 Flash";
                    reasoning = true;
                    contextWindow = 200000;
                    maxTokens = 65536;
                  }
                ];
              };

              # Declare non-secret env vars and runtime requirements
              environment = {
                variables = {
                  PI_OFFLINE = "1";
                };
                required = [
                  "ANTIGRAVITY_API_KEY"
                ];
              };
            };
          }
        ];
      };
    };
}
