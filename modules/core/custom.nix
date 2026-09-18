{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.pi;
  nixpiLib = import ../../lib {
    inherit lib pkgs;
  };

  mkExtPkg =
    name: opt:
    if opt.src != null || opt.content != null || opt.entrypoint != null then
      nixpiLib.mkPiExtension {
        pname = opt.name;
        version = opt.version;
        src = opt.src;
        content = opt.content;
        entrypoint = opt.entrypoint;
        runtimePackages = opt.runtimePackages;
        runtimeEnvironment = opt.runtimeEnvironment;
        piManifest = opt.piManifest;
        meta.description = opt.description;
      }
    else
      pkgs.runCommand "pi-extension-${name}-empty" { } ''
        mkdir -p "$out"
      '';

  customExtensionType = lib.types.submodule (
    { name, config, ... }:
    {
      options = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to enable this custom extension.";
        };

        name = lib.mkOption {
          type = lib.types.str;
          default = name;
          description = "Package name of the extension.";
        };

        version = lib.mkOption {
          type = lib.types.str;
          default = "0.1.0";
          description = "Version of the extension package.";
        };

        description = lib.mkOption {
          type = lib.types.str;
          default = "Custom Pi extension: ${name}";
          description = "Description for the extension.";
        };

        src = lib.mkOption {
          type = lib.types.nullOr (
            lib.types.oneOf [
              lib.types.path
              lib.types.package
            ]
          );
          default = null;
          description = "Source directory or package derivation for the extension.";
        };

        content = lib.mkOption {
          type = lib.types.nullOr lib.types.lines;
          default = null;
          description = "Inline JavaScript or TypeScript code for the extension entrypoint.";
        };

        entrypoint = lib.mkOption {
          type = lib.types.nullOr (
            lib.types.oneOf [
              lib.types.path
              lib.types.package
              lib.types.str
            ]
          );
          default = null;
          description = "Path or derivation of a single-file extension entrypoint.";
        };

        runtimePackages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          description = "Runtime CLI packages to place on PATH for this extension.";
        };

        runtimeEnvironment = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.oneOf [
              lib.types.str
              lib.types.int
              lib.types.bool
            ]
          );
          default = { };
          description = "Environment variables required by this extension.";
        };

        piManifest = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = { };
          description = "Extra fields to merge into the extension package.json manifest.";
        };

        package = lib.mkOption {
          type = lib.types.package;
          default = mkExtPkg name config;
          defaultText = lib.literalExpression "mkPiExtension { pname = name; ... }";
          description = "The resulting packaged extension derivation.";
        };
      };
    }
  );

  mkSkillPkg =
    name: opt:
    if opt.src != null then
      opt.src
    else
      nixpiLib.mkPiSkill {
        inherit (opt) name description runtimePackages;
        content = if opt.content != null then opt.content else "";
      };

  customSkillType = lib.types.submodule (
    { name, config, ... }:
    {
      options = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to enable this custom skill.";
        };

        name = lib.mkOption {
          type = lib.types.str;
          default = name;
          description = "Name of the skill.";
        };

        description = lib.mkOption {
          type = lib.types.str;
          default = "Custom Pi skill: ${name}";
          description = "Description of the skill.";
        };

        src = lib.mkOption {
          type = lib.types.nullOr (
            lib.types.oneOf [
              lib.types.path
              lib.types.package
            ]
          );
          default = null;
          description = "Source directory or derivation containing SKILL.md.";
        };

        content = lib.mkOption {
          type = lib.types.nullOr lib.types.lines;
          default = null;
          description = "Inline Markdown content for SKILL.md.";
        };

        runtimePackages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          description = "Runtime packages required by this skill.";
        };

        package = lib.mkOption {
          type = lib.types.package;
          default = mkSkillPkg name config;
          defaultText = lib.literalExpression "mkPiSkill { name = name; ... }";
          description = "The resulting packaged skill derivation.";
        };
      };
    }
  );

  mkPromptFile =
    name: opt:
    if opt.src != null then
      opt.src
    else
      nixpiLib.mkPiPrompt {
        inherit (opt) name description argumentHint;
        content = if opt.content != null then opt.content else "";
      };

  customPromptType = lib.types.submodule (
    { name, config, ... }:
    {
      options = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to enable this custom prompt.";
        };

        name = lib.mkOption {
          type = lib.types.str;
          default = name;
          description = "Name of the prompt.";
        };

        description = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Description of the prompt.";
        };

        argumentHint = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Argument hint for the prompt template.";
        };

        src = lib.mkOption {
          type = lib.types.nullOr (
            lib.types.oneOf [
              lib.types.path
              lib.types.package
              lib.types.str
            ]
          );
          default = null;
          description = "Prompt file path or derivation.";
        };

        content = lib.mkOption {
          type = lib.types.nullOr lib.types.lines;
          default = null;
          description = "Inline Markdown content for the prompt.";
        };

        file = lib.mkOption {
          type = lib.types.oneOf [
            lib.types.path
            lib.types.package
            lib.types.str
          ];
          default = mkPromptFile name config;
          defaultText = lib.literalExpression "mkPiPrompt { name = name; ... }";
          description = "The generated prompt template file.";
        };
      };
    }
  );

  mkThemeFile =
    name: opt:
    if opt.src != null then
      opt.src
    else if opt.colors != null then
      nixpiLib.mkPiTheme {
        inherit (opt) name colors;
      }
    else
      pkgs.writeText "${name}.json" "{}";

  customThemeType = lib.types.submodule (
    { name, config, ... }:
    {
      options = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to enable this custom theme.";
        };

        name = lib.mkOption {
          type = lib.types.str;
          default = name;
          description = "Name of the theme.";
        };

        colors = lib.mkOption {
          type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
          default = null;
          description = "Color definition attribute set.";
        };

        src = lib.mkOption {
          type = lib.types.nullOr (
            lib.types.oneOf [
              lib.types.path
              lib.types.package
              lib.types.str
            ]
          );
          default = null;
          description = "Theme JSON file path or derivation.";
        };

        file = lib.mkOption {
          type = lib.types.oneOf [
            lib.types.path
            lib.types.package
            lib.types.str
          ];
          default = mkThemeFile name config;
          defaultText = lib.literalExpression "mkPiTheme { name = name; ... }";
          description = "The generated theme JSON file.";
        };
      };
    }
  );

  enabledCustomExts = lib.filterAttrs (_: ext: ext.enable) (cfg.customExtensions or { });
  enabledCustomSkills = lib.filterAttrs (_: s: s.enable) (cfg.customSkills or { });
  enabledCustomPrompts = lib.filterAttrs (_: p: p.enable) (cfg.customPrompts or { });
  enabledCustomThemes = lib.filterAttrs (_: t: t.enable) (cfg.customThemes or { });

  extPackages = map (ext: ext.package) (builtins.attrValues enabledCustomExts);
  skillPackages = map (s: s.package) (builtins.attrValues enabledCustomSkills);
  promptFiles = map (p: p.file) (builtins.attrValues enabledCustomPrompts);
  themeFiles = map (t: t.file) (builtins.attrValues enabledCustomThemes);

  extRuntimePkgs = lib.concatMap (ext: ext.runtimePackages) (builtins.attrValues enabledCustomExts);
  skillRuntimePkgs = lib.concatMap (s: s.runtimePackages) (builtins.attrValues enabledCustomSkills);

  extEnvVars = lib.foldl' lib.recursiveUpdate { } (
    map (ext: ext.runtimeEnvironment) (builtins.attrValues enabledCustomExts)
  );
in
{
  options.programs.pi = {
    customExtensions = lib.mkOption {
      type = lib.types.attrsOf customExtensionType;
      default = { };
      description = "Declaratively defined custom extensions for Pi.";
    };

    customSkills = lib.mkOption {
      type = lib.types.attrsOf customSkillType;
      default = { };
      description = "Declaratively defined custom skills for Pi.";
    };

    customPrompts = lib.mkOption {
      type = lib.types.attrsOf customPromptType;
      default = { };
      description = "Declaratively defined custom prompts for Pi.";
    };

    customThemes = lib.mkOption {
      type = lib.types.attrsOf customThemeType;
      default = { };
      description = "Declaratively defined custom themes for Pi.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.pi = {
      packages = extPackages;
      extraSkills = skillPackages;
      prompts = promptFiles;
      themes = themeFiles;
      runtimePackages = extRuntimePkgs ++ skillRuntimePkgs;
      environment.variables = extEnvVars;
    };
  };
}
