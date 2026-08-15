{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.pi;

  # Helper to remove null values recursively
  filterNulls =
    attrs:
    lib.filterAttrs (n: v: v != null) (
      builtins.mapAttrs (
        n: v: if builtins.isAttrs v && !lib.isDerivation v then filterNulls v else v
      ) attrs
    );

  # Collect packages and runtimePackages from enabled typed extensions
  enabledExtensions = lib.filterAttrs (n: ext: ext.enable or false) (cfg.extensions or { });

  extensionPackages = lib.concatMap (
    ext:
    if ext ? package && ext.package != null then
      [ ext.package ]
    else if ext ? packages then
      ext.packages
    else
      [ ]
  ) (builtins.attrValues enabledExtensions);

  extensionRuntimePkgs = lib.concatMap (ext: ext.runtimePackages or [ ]) (
    builtins.attrValues enabledExtensions
  );

  # Extract passthru runtimePackages from all package derivations
  allPackagesList = cfg.packages ++ extensionPackages;
  passthruRuntimePkgs = lib.concatMap (
    pkg:
    if lib.isDerivation pkg && pkg ? passthru && pkg.passthru ? runtimePackages then
      pkg.passthru.runtimePackages
    else
      [ ]
  ) (allPackagesList ++ cfg.rawExtensions);

  allRuntimePackages = lib.unique (
    cfg.runtimePackages ++ extensionRuntimePkgs ++ passthruRuntimePkgs
  );

  # Stringify resource paths
  toStringPath = p: if lib.isDerivation p || builtins.isPath p then "${p}" else p;

  # Build final settings attribute set
  rawSettings = filterNulls (
    cfg.settings
    // {
      packages = map toStringPath allPackagesList;
      extensions = map toStringPath cfg.rawExtensions;
      skills = map toStringPath cfg.skills;
      prompts = map toStringPath cfg.prompts;
      themes = map toStringPath cfg.themes;
    }
  );

  # Remove empty lists if not needed
  cleanedSettings = lib.filterAttrs (n: v: !(builtins.isList v && v == [ ])) rawSettings;

  settingsJson = pkgs.writeText "pi-settings.json" (builtins.toJSON cleanedSettings);

  modelsJson =
    if cfg.providers != { } then
      pkgs.writeText "pi-models.json" (
        builtins.toJSON {
          providers = filterNulls cfg.providers;
        }
      )
    else
      null;

  # Build wrapper script
  envExports = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      k: v: "export ${k}=${lib.escapeShellArg (toString v)}"
    ) cfg.environment.variables
  );

  pathPrefix = lib.makeBinPath allRuntimePackages;

  wrapper = pkgs.writeShellScriptBin "pi" ''
    # nixpi generated wrapper for Pi Coding Agent
    set -eu

    # Add runtime dependencies to PATH
    ${lib.optionalString (allRuntimePackages != [ ]) ''
      export PATH="${pathPrefix}:$PATH"
    ''}

    # Export user environment variables
    ${envExports}

    # If PI_CODING_AGENT_DIR is not explicitly overridden, manage a writable state directory
    if [ -z "''${PI_CODING_AGENT_DIR:-}" ]; then
      STATE_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}/nixpi/agent"
      mkdir -p "$STATE_DIR"
      ln -sf "${settingsJson}" "$STATE_DIR/settings.json"
      ${lib.optionalString (modelsJson != null) ''
        ln -sf "${modelsJson}" "$STATE_DIR/models.json"
      ''}
      export PI_CODING_AGENT_DIR="$STATE_DIR"
    fi

    # Forward to base Pi binary
    exec "${cfg.package}/bin/pi" "$@"
  '';

  wrappedPackage = pkgs.symlinkJoin {
    name = "pi-configured-${cfg.package.version or "custom"}";
    paths = [
      wrapper
      cfg.package
    ];
    passthru = {
      inherit (cfg) package;
      inherit
        settingsJson
        modelsJson
        allRuntimePackages
        cleanedSettings
        ;
      unwrapped = cfg.package;
    };
  };
in
{
  options.programs.pi = {
    generatedSettingsFile = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      description = "Generated immutable settings.json derivation.";
    };

    generatedModelsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      readOnly = true;
      description = "Generated immutable models.json derivation (null if no providers defined).";
    };

    finalRuntimePackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      readOnly = true;
      description = "Combined list of all runtime packages from core, extensions, and derivations.";
    };
  };

  config.programs.pi = {
    finalPackage = wrappedPackage;
    generatedSettingsFile = settingsJson;
    generatedModelsFile = modelsJson;
    finalRuntimePackages = allRuntimePackages;
  };
}
