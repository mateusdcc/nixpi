{
  description = "Deprecated learning environment compatibility template";

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
          learningPi = nixpi.lib.makePi {
            inherit pkgs;
            modules = [ nixpi.piModules.profiles.learning ];
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
          };
        }
      );
    };
}
