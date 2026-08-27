{
  pkgs,
  mkPiExtension,
  duckdb ? pkgs.duckdb,
  python3 ? pkgs.python3,
  curl ? pkgs.curl,
  jq ? pkgs.jq,
}:

let
  duckdbPython = import ../../../lib/duckdb-python.nix { inherit pkgs python3; };
  pyEnv = python3.withPackages (ps: [
    duckdbPython
    ps.youtube-transcript-api
  ]);
in
mkPiExtension {
  pname = "research-tools";
  version = "0.1.0";
  runtimePackages = [
    duckdb
    pyEnv
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
    description = "Pi research extension for evidence-first legal tech opportunity discovery";
    license = pkgs.lib.licenses.mit;
  };
}
