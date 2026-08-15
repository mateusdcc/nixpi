{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.pi.extensions.ripgrep-search;
  rgPkg = pkgs.callPackage ../../packages/extensions/ripgrep-search {
    mkPiExtension = pkgs.callPackage ../../lib/mk-extension.nix { };
  };
in
{
  options.programs.pi.extensions.ripgrep-search = {
    enable = lib.mkEnableOption "Pi ripgrep-search extension";

    package = lib.mkOption {
      type = lib.types.package;
      default = rgPkg;
      defaultText = lib.literalExpression "pkgs.piExtensions.ripgrep-search";
      description = "Package providing the ripgrep-search extension.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.pi.runtimePackages = [ pkgs.ripgrep ];
  };
}
