{
  pkgs,
  modules ? [ ],
  extraSpecialArgs ? { },
}:

let
  lib = pkgs.lib;
  coreModule = import ../modules;
in
lib.evalModules {
  modules = [ coreModule ] ++ (if builtins.isList modules then modules else [ modules ]);
  specialArgs = {
    inherit pkgs;
  }
  // extraSpecialArgs;
}
