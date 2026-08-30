{
  pkgs,
  python3 ? pkgs.python3,
  duckdb ? pkgs.duckdb,
}:

let
  duckdbPython = import ../../lib/duckdb-python.nix { inherit pkgs python3; };
  pyEnv = python3.withPackages (_: [ duckdbPython ]);
in
pkgs.stdenv.mkDerivation {
  pname = "pi-evidence-ledger";
  version = "0.1.0";
  src = pkgs.lib.cleanSource ./.;

  nativeBuildInputs = [ pkgs.makeWrapper ];
  buildInputs = [
    pyEnv
    duckdb
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/share/evidence-ledger"
    cp schema.sql seed.sql "$out/share/evidence-ledger/"
    cp evidence-ledger.py "$out/share/evidence-ledger/evidence-ledger.py"
    chmod +x "$out/share/evidence-ledger/evidence-ledger.py"

    makeWrapper "$out/share/evidence-ledger/evidence-ledger.py" "$out/bin/evidence-ledger" \
      --prefix PATH : "${
        pkgs.lib.makeBinPath [
          pyEnv
          duckdb
        ]
      }"
    runHook postInstall
  '';

  passthru = {
    runtimePackages = [
      pyEnv
      duckdb
    ];
  };

  meta = {
    description = "DuckDB Evidence Ledger schema and CLI manager for Pi";
    license = pkgs.lib.licenses.mit;
  };
}
