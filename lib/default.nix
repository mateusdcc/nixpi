{
  lib,
  pkgs ? null,
}:

let
  deprecation = import ./deprecation.nix { inherit lib; };
  factories = import ./module-factories.nix { inherit lib; };
  withPkgs =
    builder: args:
    let
      resolvedPkgs = if pkgs != null then pkgs else args.pkgs or (throw "nixpi: `pkgs` is required");
    in
    builder resolvedPkgs (builtins.removeAttrs args [ "pkgs" ]);
in
{
  inherit deprecation;

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

  mkPiExtension = withPkgs (
    resolvedPkgs:
    import ./mk-extension.nix {
      pkgs = resolvedPkgs;
      inherit lib;
    }
  );

  mkPiProvider = withPkgs (
    resolvedPkgs:
    import ./mk-provider.nix {
      pkgs = resolvedPkgs;
      inherit lib;
    }
  );

  mkPiSkill = withPkgs (
    resolvedPkgs:
    (import ./mk-resource.nix {
      pkgs = resolvedPkgs;
      inherit lib;
    }).mkPiSkill
  );

  mkPiPrompt = withPkgs (
    resolvedPkgs:
    (import ./mk-resource.nix {
      pkgs = resolvedPkgs;
      inherit lib;
    }).mkPiPrompt
  );

  mkPiTheme = withPkgs (
    resolvedPkgs:
    (import ./mk-resource.nix {
      pkgs = resolvedPkgs;
      inherit lib;
    }).mkPiTheme
  );

  inherit (factories)
    mkPiExtensionModule
    mkPiSkillModule
    mkPiProviderModule
    ;
}
