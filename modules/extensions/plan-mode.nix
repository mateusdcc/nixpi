{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.pi.extensions.plan-mode;
  planPkg = pkgs.callPackage ../../packages/extensions/plan-mode {
    mkPiExtension = pkgs.callPackage ../../lib/mk-extension.nix { };
  };
in
{
  options.programs.pi.extensions.plan-mode = {
    enable = lib.mkEnableOption "Pi plan-mode extension";

    package = lib.mkOption {
      type = lib.types.package;
      default = planPkg;
      defaultText = lib.literalExpression "pkgs.piExtensions.plan-mode";
      description = "Package providing the plan-mode extension.";
    };

    mode = lib.mkOption {
      type = lib.types.enum [
        "fast"
        "balanced"
        "thorough"
      ];
      default = "balanced";
      description = "Planning execution mode.";
    };

    maxSteps = lib.mkOption {
      type = lib.types.int;
      default = 10;
      description = "Maximum number of steps in plan execution.";
    };

    autoApprove = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to automatically approve plan steps.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.pi.settings.planMode = {
      inherit (cfg) mode maxSteps autoApprove;
    };
  };
}
