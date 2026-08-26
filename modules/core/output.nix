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

  # Collect packages, runtimePackages, and env vars from enabled providers
  enabledProviders = lib.filterAttrs (n: prov: prov.enable or true) (cfg.providers or { });

  providerPackages = lib.concatMap (
    prov:
    if prov ? package && prov.package != null then
      [ prov.package ]
    else if prov ? packages then
      prov.packages
    else
      [ ]
  ) (builtins.attrValues enabledProviders);

  providerRuntimePkgs = lib.concatMap (prov: prov.runtimePackages or [ ]) (
    builtins.attrValues enabledProviders
  );

  providerEnvVars = lib.foldl' lib.recursiveUpdate { } (
    map (prov: prov.environment.variables or { }) (builtins.attrValues enabledProviders)
  );

  # Collect packages and runtimePackages from enabled typed skills
  enabledSkills =
    if builtins.isAttrs (cfg.skills or { }) then
      lib.filterAttrs (n: skill: skill.enable or false) (cfg.skills or { })
    else
      { };

  skillPackages = lib.concatMap (
    skill:
    if builtins.isAttrs skill then
      (if skill ? package && skill.package != null then [ skill.package ] else [ ])
      ++ (if skill ? packages then skill.packages else [ ])
    else if lib.isDerivation skill || builtins.isPath skill || builtins.isString skill then
      [ skill ]
    else
      [ ]
  ) (if builtins.isList (cfg.skills or { }) then cfg.skills else builtins.attrValues enabledSkills);

  skillRuntimePkgs = lib.concatMap (
    skill: if builtins.isAttrs skill then skill.runtimePackages or [ ] else [ ]
  ) (if builtins.isList (cfg.skills or { }) then cfg.skills else builtins.attrValues enabledSkills);

  allSkillsList = skillPackages ++ (cfg.rawSkills or [ ]) ++ (cfg.extraSkills or [ ]);
  allExtensionsList = (cfg.rawExtensions or [ ]) ++ (cfg.extraExtensions or [ ]);

  # Extract passthru runtimePackages from all package derivations
  allPackagesList = cfg.packages ++ extensionPackages ++ providerPackages;
  passthruRuntimePkgs = lib.concatMap (
    pkg:
    if lib.isDerivation pkg && pkg ? passthru && pkg.passthru ? runtimePackages then
      pkg.passthru.runtimePackages
    else
      [ ]
  ) (allPackagesList ++ allExtensionsList ++ allSkillsList);

  allRuntimePackages = lib.unique (
    cfg.runtimePackages
    ++ (cfg.extraPackages or [ ])
    ++ extensionRuntimePkgs
    ++ providerRuntimePkgs
    ++ skillRuntimePkgs
    ++ passthruRuntimePkgs
  );

  # Stringify resource paths
  toStringPath = p: if lib.isDerivation p || builtins.isPath p then "${p}" else p;

  # Build final settings attribute set
  rawSettings = filterNulls (
    cfg.settings
    // {
      packages = map toStringPath allPackagesList;
      extensions = map toStringPath allExtensionsList;
      skills = map toStringPath allSkillsList;
      prompts = map toStringPath cfg.prompts;
      themes = map toStringPath cfg.themes;
    }
  );

  # Remove empty lists if not needed
  cleanedSettings = lib.filterAttrs (n: v: !(builtins.isList v && v == [ ])) rawSettings;

  settingsJson = pkgs.writeText "pi-settings.json" (builtins.toJSON cleanedSettings);

  # Collect providers with static endpoint declarations for models.json
  staticProviders =
    lib.filterAttrs
      (n: prov: (prov ? baseUrl && prov.baseUrl != null) || (prov ? api && prov.api != null))
      (
        builtins.mapAttrs (n: prov: {
          inherit (prov)
            baseUrl
            api
            apiKey
            ;
          models =
            if builtins.isAttrs (prov.models or null) then
              builtins.attrValues prov.models
            else if builtins.isList (prov.models or null) then
              prov.models
            else
              [ ];
        }) enabledProviders
      );

  cleanedProviders = filterNulls staticProviders;

  modelsJson =
    if cleanedProviders != { } then
      pkgs.writeText "pi-models.json" (
        builtins.toJSON {
          providers = cleanedProviders;
        }
      )
    else
      null;

  # Build wrapper script
  allEnvVars = cfg.environment.variables // providerEnvVars;
  envExports = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (k: v: "export ${k}=${lib.escapeShellArg (toString v)}") allEnvVars
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

  allAssertions = (cfg.assertions or [ ]) ++ (config.assertions or [ ]);
  failedAssertions = builtins.filter (x: !x.assertion) allAssertions;
  assertMessages = lib.concatStringsSep "\n" (map (x: "- " + x.message) failedAssertions);
  checkedPackage =
    if failedAssertions != [ ] then
      throw "\nFailed assertions in Pi configuration:\n${assertMessages}"
    else
      wrappedPackage;

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
    finalPackage = checkedPackage;
    generatedSettingsFile = settingsJson;
    generatedModelsFile = modelsJson;
    finalRuntimePackages = allRuntimePackages;
  };
}
