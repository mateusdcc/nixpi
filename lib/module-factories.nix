{ lib }:

{
  mkPiExtensionModule =
    {
      name,
      description ? null,
      package ? null,
      defaultPackage ? null,
      runtimePackages ? [ ],
      extraPackages ? [ ],
      settingsOptions ? { },
      settingsExample ? null,
      settingsDescription ? "Settings configuration for the ${name} extension.",
      extraOptions ? { },
      extraConfig ? cfg: { },
    }:
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.programs.pi.extensions.${name};
      resolvedPkg =
        if package != null then
          package
        else if defaultPackage != null then
          (if lib.isFunction defaultPackage then defaultPackage pkgs else defaultPackage)
        else
          null;
    in
    {
      options.programs.pi.extensions.${name} = {
        enable = lib.mkEnableOption (if description != null then description else "Pi ${name} extension");

        package = lib.mkOption {
          type = lib.types.nullOr lib.types.package;
          default = resolvedPkg;
          defaultText =
            if resolvedPkg != null then lib.literalExpression "pkgs.piExtensions.${name}" else null;
          description = "Package providing the ${name} extension.";
        };

        runtimePackages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = runtimePackages;
          description = "Additional runtime packages required by the ${name} extension.";
        };
      }
      // (lib.optionalAttrs (settingsOptions != { }) {
        settings = lib.mkOption {
          type = lib.types.submodule {
            options = settingsOptions;
          };
          default = { };
          description = settingsDescription;
        };
      })
      // extraOptions;

      config = lib.mkIf cfg.enable (
        lib.mkMerge [
          (lib.optionalAttrs (extraPackages != [ ]) {
            programs.pi.extraPackages = extraPackages;
          })
          (extraConfig cfg)
        ]
      );
    };

  mkPiSkillModule =
    {
      name,
      description ? null,
      package ? null,
      defaultPackage ? null,
      runtimePackages ? [ ],
      extraPackages ? [ ],
      extraOptions ? { },
      extraConfig ? cfg: { },
    }:
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.programs.pi.skills.${name};
      resolvedPkg =
        if package != null then
          package
        else if defaultPackage != null then
          (if lib.isFunction defaultPackage then defaultPackage pkgs else defaultPackage)
        else
          null;
    in
    {
      options.programs.pi.skills.${name} = {
        enable = lib.mkEnableOption (if description != null then description else "Pi ${name} skill");

        package = lib.mkOption {
          type = lib.types.nullOr lib.types.package;
          default = resolvedPkg;
          defaultText = if resolvedPkg != null then lib.literalExpression "pkgs.piSkills.${name}" else null;
          description = "Package providing the ${name} skill.";
        };

        runtimePackages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = runtimePackages;
          description = "Additional runtime packages required by the ${name} skill.";
        };
      }
      // extraOptions;

      config = lib.mkIf cfg.enable (
        lib.mkMerge [
          (lib.optionalAttrs (extraPackages != [ ]) {
            programs.pi.extraPackages = extraPackages;
          })
          (extraConfig cfg)
        ]
      );
    };

  mkPiProviderModule =
    {
      name,
      description ? null,
      package ? null,
      defaultPackage ? null,
      baseUrl ? null,
      api ? null,
      apiKey ? null,
      models ? { },
      runtimePackages ? [ ],
      extraPackages ? [ ],
      extraConfig ? cfg: { },
    }:
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      resolvedPkg =
        if package != null then
          package
        else if defaultPackage != null then
          (if lib.isFunction defaultPackage then defaultPackage pkgs else defaultPackage)
        else
          null;
      cfg = config.programs.pi.providers.${name};
    in
    {
      config = lib.mkMerge [
        {
          programs.pi.providers.${name} = {
            package = lib.mkDefault resolvedPkg;
            runtimePackages = lib.mkDefault runtimePackages;
          }
          // lib.optionalAttrs (baseUrl != null) { baseUrl = lib.mkDefault baseUrl; }
          // lib.optionalAttrs (api != null) { api = lib.mkDefault api; }
          // lib.optionalAttrs (apiKey != null) { apiKey = lib.mkDefault apiKey; }
          // lib.optionalAttrs (models != { }) { models = lib.mkDefault models; };
        }
        (lib.optionalAttrs (extraPackages != [ ]) {
          programs.pi.extraPackages = extraPackages;
        })
        (extraConfig cfg)
      ];
    };
}
