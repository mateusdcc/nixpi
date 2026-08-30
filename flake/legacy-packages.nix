{
  nixpkgs,
  systems,
}:

{
  legacyPackages = nixpkgs.lib.genAttrs systems (
    system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      nixpiLib = import ../lib {
        lib = pkgs.lib;
        inherit pkgs;
      };
    in
    {
      makePiWithModule =
        {
          module ? { },
          modules ? [ ],
          extraSpecialArgs ? { },
        }:
        nixpiLib.makePi {
          inherit pkgs extraSpecialArgs;
          modules = (if module != { } then [ module ] else [ ]) ++ modules;
        };
      makePi =
        modules:
        nixpiLib.makePi {
          inherit pkgs;
          modules = if builtins.isList modules then modules else [ modules ];
        };
    }
  );
}
