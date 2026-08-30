{
  pkgs,
  modules ? [ ],
  extraSpecialArgs ? { },
}:

let
  lib = pkgs.lib;
  evalPi = import ./eval-pi.nix;

  mkPiInstance =
    currentModules:
    let
      evaluated = evalPi {
        inherit pkgs extraSpecialArgs;
        modules = currentModules;
      };
      extend =
        extension:
        mkPiInstance (currentModules ++ (if builtins.isList extension then extension else [ extension ]));
    in
    evaluated.config.programs.pi.finalPackage.overrideAttrs (old: {
      passthru = (old.passthru or { }) // {
        inherit (evaluated) config options;
        inherit extend;
        unwrapped = evaluated.config.programs.pi.package;
      };
    });
in
mkPiInstance modules
