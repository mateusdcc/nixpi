{
  pkgs,
  nixpiLib,
  legalResearchProfile,
}:

let
  pyEnv = pkgs.python3.withPackages (ps: [
    ps.duckdb
    ps.youtube-transcript-api
  ]);
  configuredPi = nixpiLib.makePi {
    inherit pkgs;
    modules = [
      legalResearchProfile
      {
        programs.pi = {
          settings.defaultProvider = "openai";
        };
      }
    ];
  };
in
pkgs.runCommand "nixpi-legal-research-test"
  {
    buildInputs = [
      configuredPi
      pkgs.duckdb
      pyEnv
      pkgs.jq
    ];
  }
  ''
    set -eu

    export HOME="$TMPDIR/fake-home"
    export XDG_DATA_HOME="$TMPDIR/fake-home/.local/share"
    mkdir -p "$HOME" "$XDG_DATA_HOME"

    export PI_OFFLINE=1
    export PI_SKIP_VERSION_CHECK=1
    export PI_TELEMETRY=0

    # 1. Test Pi binary invocation
    "${configuredPi}/bin/pi" --version

    # 2. Verify wrapper PATH contains duckdb and python3
    grep -q "duckdb" "${configuredPi}/bin/pi"
    grep -q "python3" "${configuredPi}/bin/pi"

    # 3. Check generated settings.json contains all 8 legal research skills
    SETTINGS="${configuredPi.passthru.settingsJson}"
    grep -q "legal-pain-discovery" "$SETTINGS"
    grep -q "voice-of-customer-mining" "$SETTINGS"
    grep -q "evidence-deduplication" "$SETTINGS"
    grep -q "legal-market-segmentation" "$SETTINGS"
    grep -q "competitor-gap-analysis" "$SETTINGS"
    grep -q "brazil-localization-test" "$SETTINGS"
    grep -q "opportunity-scoring" "$SETTINGS"
    grep -q "product-opportunity-report" "$SETTINGS"
    grep -q "research-lawyer-opportunities" "$SETTINGS"

    # 4. Verify DuckDB evidence ledger schema and seed data
    DB_PATH="$TMPDIR/test-ledger.duckdb"
    duckdb "$DB_PATH" < "${../../packages/evidence-ledger/schema.sql}"
    duckdb "$DB_PATH" < "${../../packages/evidence-ledger/seed.sql}"

    # Verify tables count
    COUNT_SEGMENTS=$(duckdb "$DB_PATH" -noheader -list -c "SELECT COUNT(*) FROM lawyer_segments;")
    test "$COUNT_SEGMENTS" -eq 6

    COUNT_WORKFLOWS=$(duckdb "$DB_PATH" -noheader -list -c "SELECT COUNT(*) FROM workflows;")
    test "$COUNT_WORKFLOWS" -eq 13

    # Verify validation view works
    duckdb "$DB_PATH" -c "SELECT * FROM validated_opportunities_view LIMIT 0;"

    echo "NixPi legal research tests passed successfully" > "$out"
  ''
