{ lib, ... }:

{
  options.programs.pi.environment = {
    variables = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.nullOr (
          lib.types.oneOf [
            lib.types.str
            lib.types.int
            lib.types.bool
            lib.types.path
          ]
        )
      );
      default = { };
      description = ''
        Non-secret environment variables to export for Pi.
        DO NOT put secret API keys here as they will be written into the Nix store.
      '';
    };

    required = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        List of environment variable names required by enabled extensions or providers.
        These are checked or documented as runtime requirements.
      '';
    };

    optional = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        List of optional environment variable names supported by the configuration.
      '';
    };
  };
}
