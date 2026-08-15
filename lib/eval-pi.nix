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
  modules = [ coreModule ] ++ modules;
  specialArgs = {
    inherit pkgs;
  }
  // extraSpecialArgs;
}
