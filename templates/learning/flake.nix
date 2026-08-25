{
  description = "Learning & Obsidian vault development shell with Pi";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpi.url = "github:mateusdcc/nixpi";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpi,
      ...
    }:
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
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          learningPi = nixpi.lib.makePi {
            inherit pkgs;
            modules = [
              nixpi.piModules.profiles.learning
              (
                { config, ... }:
                {
                  programs.pi = {
                    providers.antigravity.enable = true;
                    settings = {
                      defaultProvider = config.programs.pi.providers.antigravity;
                      defaultModel = config.programs.pi.providers.antigravity.models."gemini-3.7-flash";
                    };
                  };
                }
              )
            ];
          };
        in
        {
          default = pkgs.mkShell {
            packages = [
              learningPi
              pkgs.glow
              pkgs.ripgrep
              pkgs.python3
            ];

            shellHook = ''
              echo "🎓 Loaded learning devShell with configured Pi (${learningPi.name})"
            '';
          };
        }
      );
    };
}
