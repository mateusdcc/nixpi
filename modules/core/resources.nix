{ lib, pkgs, ... }:

let
  rawResourceListType = lib.types.listOf (
    lib.types.oneOf [
      lib.types.package
      lib.types.path
      lib.types.str
    ]
  );
in
{
  options.programs.pi = {
    runtimePackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "List of CLI packages to make available in PATH for Pi and its extensions.";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Extra CLI packages to make available in PATH for Pi (alias/escape hatch for runtimePackages).";
    };

    packages = lib.mkOption {
      type = rawResourceListType;
      default = [ ];
      description = "List of Pi packages (derivations or directory paths) to load.";
    };

    rawExtensions = lib.mkOption {
      type = rawResourceListType;
      default = [ ];
      description = "List of standalone extension file paths or derivations to load.";
    };

    extraExtensions = lib.mkOption {
      type = rawResourceListType;
      default = [ ];
      description = "Extra standalone extension file paths or derivations to load.";
    };

    rawSkills = lib.mkOption {
      type = rawResourceListType;
      default = [ ];
      description = "List of standalone skill directory paths or derivations to load.";
    };

    extraSkills = lib.mkOption {
      type = rawResourceListType;
      default = [ ];
      description = "Extra standalone skill directory paths or derivations to load.";
    };

    prompts = lib.mkOption {
      type = rawResourceListType;
      default = [ ];
      description = "List of prompt template files or derivations to load.";
    };

    themes = lib.mkOption {
      type = rawResourceListType;
      default = [ ];
      description = "List of theme JSON files or derivations to load.";
    };
  };
}
