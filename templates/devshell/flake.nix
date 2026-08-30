{
  description = "Project-specific development shell with Pi";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
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
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          projectPi = nixpi.lib.makePi {
            inherit pkgs;
            modules = [
              {
                programs.pi = {
                  enable = true;
                  settings = {
                    defaultProvider = "openai";
                    defaultModel = "gpt-4o";
                  };
                  extensions = {
                    ripgrep-search.enable = true;
                  };
                };
              }
            ];
          };
        in
        {
          default = pkgs.mkShell {
            packages = [
              projectPi
              pkgs.git
              pkgs.ripgrep
            ];

            shellHook = ''
              echo "Loaded project devShell with configured Pi (${projectPi.name})"
            '';
          };
        }
      );
    };
}
