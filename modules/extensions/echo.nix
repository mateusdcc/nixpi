{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.pi.extensions.echo;
  echoPkg = pkgs.callPackage ../../packages/extensions/echo {
    mkPiExtension = pkgs.callPackage ../../lib/mk-extension.nix { };
  };
in
{
  options.programs.pi.extensions.echo = {
    enable = lib.mkEnableOption "Pi echo extension";

    package = lib.mkOption {
      type = lib.types.package;
      default = echoPkg;
      defaultText = lib.literalExpression "pkgs.piExtensions.echo";
      description = "Package providing the echo extension.";
    };
  };
}
