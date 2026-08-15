{
  lib,
  pkgs,
  ...
}:

{
  options.programs.pi = {
    enable = lib.mkEnableOption "Pi coding agent";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.pi-coding-agent;
      defaultText = lib.literalExpression "pkgs.pi-coding-agent";
      description = "The base Pi coding agent package to use.";
    };

    assertions = lib.mkOption {
      type = lib.types.listOf lib.types.unspecified;
      default = [ ];
      description = "List of assertions to check during evaluation.";
    };

    finalPackage = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      description = "The fully configured and wrapped Pi coding agent package.";
    };
  };
}
