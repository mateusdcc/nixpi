{
  pkgs,
  python3 ? pkgs.python3,
}:

let
  duckdb = python3.pkgs.duckdb;
  isIntelDarwin = pkgs.stdenv.hostPlatform.isDarwin && pkgs.stdenv.hostPlatform.isx86_64;
in
if isIntelDarwin then
  duckdb.overridePythonAttrs (_: {
    doCheck = false;
    nativeCheckInputs = [ ];
  })
else
  duckdb
