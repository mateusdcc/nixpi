{
  pkgs,
  mkPiExtension,
  curl ? pkgs.curl,
  jq ? pkgs.jq,
}:

mkPiExtension {
  pname = "obsidian";
  version = "0.1.0";
  runtimePackages = [
    curl
    jq
  ];

  src = pkgs.lib.cleanSourceWith {
    src = ./.;
    filter =
      path: type:
      let
        base = baseNameOf path;
      in
      base != "tests" && !pkgs.lib.hasSuffix ".test.js" base;
  };

  meta = {
    description = "Pi extension to connect and control Obsidian vaults, notes, commands, settings, and plugins";
    license = pkgs.lib.licenses.mit;
  };
}
