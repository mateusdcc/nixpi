{
  description = "Standalone configured Pi coding agent environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpi.url = "github:mateusdcc/nixpi";
  };

  outputs =
    { nixpkgs, nixpi, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = nixpi.lib.makePi {
            inherit pkgs;
            modules = [
              {
                programs.pi = {
                  enable = true;
                  settings = {
                    defaultProvider = "openai";
                    defaultThinkingLevel = "medium";
                    theme = "dark";
                  };
                  extensions = {
                    echo.enable = true;
                    ripgrep-search.enable = true;
                  };
                  runtimePackages = with pkgs; [
                    git
                    jq
                  ];
                };
              }
            ];
          };
        }
      );
    };
}
