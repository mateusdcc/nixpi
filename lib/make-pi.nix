{
  pkgs,
  modules ? [ ],
  extraSpecialArgs ? { },
}:

let
  evalPi = import ./eval-pi.nix;
  evaluated = evalPi {
    inherit pkgs modules extraSpecialArgs;
  };
in
evaluated.config.programs.pi.finalPackage
