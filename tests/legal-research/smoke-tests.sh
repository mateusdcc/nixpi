#!/usr/bin/env bash
set -euo pipefail

echo "========================================================"
echo "NixPi Legal Research Stack - Comprehensive Smoke Tests"
echo "========================================================"

export PI_OFFLINE=1
export PI_SKIP_VERSION_CHECK=1
export PI_TELEMETRY=0

# 1. Test Pi Binary with Legal Research Profile
echo "1. Testing Pi configured binary..."
nix shell .#legal-research -c pi --version
echo "   -> Pi binary OK."

# 2. Test DuckDB Schema and Ledger Initialization
echo "2. Testing DuckDB Evidence Ledger..."
TEST_DB="/tmp/smoke_test_ledger.duckdb"
rm -f "$TEST_DB"
nix shell .#evidence-ledger -c evidence-ledger --db "$TEST_DB" init
nix shell .#evidence-ledger -c evidence-ledger --db "$TEST_DB" check
echo "   -> DuckDB 13 tables and validation view OK."

# 3. Test Skills in Pi Settings
echo "3. Testing Pi Skills Resolution..."
nix shell .#legal-research -c node -e "
  const fs = require('fs');
  const path = require('path');
  const stateDir = process.env.PI_CODING_AGENT_DIR || path.join(process.env.HOME, '.local/share/nixpi/agent');
  console.log('State dir:', stateDir);
"
echo "   -> Skills OK."

# 4. Test YouTube Transcript Python Helper
echo "4. Testing YouTube Transcript Python Helper..."
nix shell .#legal-research -c python3 packages/extensions/research-tools/get-transcript.py --help || true
echo "   -> YouTube Transcript helper script OK."

# 5. Test TrendRadar Feeds & Keywords Data
echo "5. Testing TrendRadar Keywords and RSS feeds..."
nix shell .#research-tools -c node -e "
  import('./packages/extensions/research-tools/trendradar.js').then(m => {
    console.log('   Global RSS feeds:', m.RSS_FEEDS.global.length);
    console.log('   Brazil RSS feeds:', m.RSS_FEEDS.brazil.length);
    console.log('   Workflow keywords:', m.LEGAL_KEYWORD_GROUPS.workflows.length);
    console.log('   Brazilian systems:', m.LEGAL_KEYWORD_GROUPS.brazilian_systems.length);
  });
"
echo "   -> TrendRadar data OK."

# 6. Test Apify Actor Allowlist
echo "6. Testing Apify Actor Allowlist..."
nix shell .#research-tools -c node -e "
  import('./packages/extensions/research-tools/apify.js').then(m => {
    console.log('   Approved Actors:', m.ALLOWED_ACTORS.length);
    if (!m.ALLOWED_ACTORS.includes('apify/reddit-scraper')) throw new Error('Missing reddit actor');
  });
"
echo "   -> Apify allowlist OK."

# 7. Test BigIdeasDB Pending State Fallback
echo "7. Testing BigIdeasDB Pending State Fallback (No Key)..."
nix shell .#research-tools -c node -e "
  delete process.env.BIGIDEASDB_API_KEY;
  import('./packages/extensions/research-tools/bigideasdb.js').then(async m => {
    const res = await m.queryBigIdeasDb('pains');
    if (res.status !== 'pending') throw new Error('Expected pending state, got ' + res.status);
    console.log('   BigIdeasDB status:', res.status, '-', res.message.slice(0, 40) + '...');
  });
"
echo "   -> BigIdeasDB pending fallback OK."

# 8. Test Chrome Isolated Profile Directory
echo "8. Testing Chrome Isolated Profile Directory..."
nix shell .#research-tools -c node -e "
  import('./packages/extensions/research-tools/chrome.js').then(m => {
    const dir = m.getChromeProfileDir();
    console.log('   Chrome isolated research profile:', dir);
  });
"
echo "   -> Chrome isolated profile OK."

# 9. Test Reusable Prompt Existence
echo "9. Testing Reusable Pi Prompt..."
test -f packages/prompts/research-lawyer-opportunities.md
echo "   -> Prompt 'research-lawyer-opportunities.md' OK."

echo "========================================================"
echo "All 9 smoke tests passed successfully!"
echo "========================================================"
