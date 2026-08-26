{
  lib,
  pkgs ? null,
}:

let
  mkResource = if pkgs != null then import ./mk-resource.nix { inherit lib pkgs; } else { };
  factories = import ./module-factories.nix { inherit lib; };
in
{
  evalPi =
    {
      pkgs,
      modules ? [ ],
      extraSpecialArgs ? { },
    }:
    import ./eval-pi.nix {
      inherit pkgs modules extraSpecialArgs;
    };

  makePi =
    {
      pkgs,
      modules ? [ ],
      extraSpecialArgs ? { },
    }:
    import ./make-pi.nix {
      inherit pkgs modules extraSpecialArgs;
    };

  mkPiExtension =
    if pkgs != null then
      import ./mk-extension.nix { inherit lib pkgs; }
    else
      args: import ./mk-extension.nix args;

  mkPiProvider =
    if pkgs != null then
      import ./mk-provider.nix { inherit lib pkgs; }
    else
      args: import ./mk-provider.nix args;

  mkPiSkill = mkResource.mkPiSkill or null;
  mkPiPrompt = mkResource.mkPiPrompt or null;
  mkPiTheme = mkResource.mkPiTheme or null;

  inherit (factories)
    mkPiExtensionModule
    mkPiSkillModule
    mkPiProviderModule
    ;
}
