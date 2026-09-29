#!/usr/bin/env bash
# tests/unit/test-updater.sh
# Regression test suite for scripts/update-upstream.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
UPDATER_SCRIPT="${UPDATER_SCRIPT:-$REPO_ROOT/scripts/update-upstream.sh}"

PASSED_COUNT=0
FAILED_COUNT=0

assert_eq() {
  local expected="$1"
  local actual="$2"
  local test_name="$3"

  if [ "$expected" = "$actual" ]; then
    printf "  [PASS] %s\n" "$test_name"
    PASSED_COUNT=$((PASSED_COUNT + 1))
  else
    printf "  [FAIL] %s: expected '%s', got '%s'\n" "$test_name" "$expected" "$actual"
    FAILED_COUNT=$((FAILED_COUNT + 1))
  fi
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local test_name="$3"

  if echo "$haystack" | grep -Fq "$needle"; then
    printf "  [PASS] %s\n" "$test_name"
    PASSED_COUNT=$((PASSED_COUNT + 1))
  else
    printf "  [FAIL] %s: '%s' not found in output\n" "$test_name" "$needle"
    FAILED_COUNT=$((FAILED_COUNT + 1))
  fi
}

printf "Running updater test suite...\n\n"

# Test 1: --check with matching versions (exit code 0)
printf "Test 1: --check with matching versions (exit 0)\n"
set +e
OUT1=$(NIXPI_TEST_CURRENT_VERSION="0.87.1" NIXPI_TEST_LATEST_VERSION="0.87.1" "$UPDATER_SCRIPT" --check)
CODE1=$?
set -e
assert_eq "0" "$CODE1" "Matching versions should exit with code 0"
assert_contains "$OUT1" "Status: Up to date" "Output should indicate up to date"

# Test 2: --check with outdated versions (exit code 2)
printf "\nTest 2: --check with outdated versions (exit 2)\n"
set +e
OUT2=$(NIXPI_TEST_CURRENT_VERSION="0.75.4" NIXPI_TEST_LATEST_VERSION="0.87.1" "$UPDATER_SCRIPT" --check)
CODE2=$?
set -e
assert_eq "2" "$CODE2" "Outdated version should exit with code 2"
assert_contains "$OUT2" "Status: Upstream npm is ahead of Nixpkgs" "Output should indicate upstream is ahead"
assert_contains "$OUT2" "not yet available in Nixpkgs" "Output should specify not yet available in Nixpkgs"

# Test 3: --check --json with matching and outdated versions
printf "\nTest 3: --check --json structured output\n"
set +e
JSON_MATCH=$(NIXPI_TEST_CURRENT_VERSION="0.87.1" NIXPI_TEST_LATEST_VERSION="0.87.1" "$UPDATER_SCRIPT" --check --json)
JSON_MATCH_CODE=$?
set -e
assert_eq "0" "$JSON_MATCH_CODE" "Matching JSON check should exit 0"
HAS_UPDATE_MATCH=$(echo "$JSON_MATCH" | jq -r '.hasUpdate')
assert_eq "false" "$HAS_UPDATE_MATCH" "JSON hasUpdate should be false when matching"

set +e
JSON_DIFF=$(NIXPI_TEST_CURRENT_VERSION="0.75.4" NIXPI_TEST_LATEST_VERSION="0.87.1" "$UPDATER_SCRIPT" --check --json)
JSON_DIFF_CODE=$?
set -e
assert_eq "2" "$JSON_DIFF_CODE" "Outdated JSON check should exit 2"
HAS_UPDATE_DIFF=$(echo "$JSON_DIFF" | jq -r '.hasUpdate')
CURRENT_VAL=$(echo "$JSON_DIFF" | jq -r '.current')
LATEST_VAL=$(echo "$JSON_DIFF" | jq -r '.latest')
assert_eq "true" "$HAS_UPDATE_DIFF" "JSON hasUpdate should be true when outdated"
assert_eq "0.75.4" "$CURRENT_VAL" "JSON current should be 0.75.4"
assert_eq "0.87.1" "$LATEST_VAL" "JSON latest should be 0.87.1"

# Test 4: Truthful reporting when upstream npm is ahead of Nixpkgs
printf "\nTest 4: Truthful reporting when upstream npm is ahead of Nixpkgs\n"
set +e
OUT4=$(NIXPI_TEST_CURRENT_VERSION="0.75.4" NIXPI_TEST_LATEST_VERSION="0.87.1" "$UPDATER_SCRIPT" --check)
set -e
assert_contains "$OUT4" "Packaged Pi version: 0.75.4" "Truthful packaged version displayed"
assert_contains "$OUT4" "Upstream npm version: 0.87.1" "Truthful upstream npm version displayed"
assert_contains "$OUT4" "npm: 0.87.1, Nixpkgs packaged: 0.75.4" "Status clearly distinguishes npm from Nixpkgs"

# Test 5: Error handling on invalid flags
printf "\nTest 5: Error handling on invalid flags (exit 1)\n"
set +e
OUT5=$("$UPDATER_SCRIPT" --invalid-flag 2>&1)
CODE5=$?
set -e
assert_eq "1" "$CODE5" "Invalid option should exit with code 1"
assert_contains "$OUT5" "Error: Unknown option: --invalid-flag" "Error message printed for unknown option"
assert_contains "$OUT5" "Usage:" "Usage printed on error"

# Test 6: Error handling on upstream fetch failure
printf "\nTest 6: Error handling on network / fetch failure (exit 1)\n"
set +e
OUT6=$(PACKAGE_NAME="invalid-nonexistent-package-xyz-12345" "$UPDATER_SCRIPT" --check 2>&1)
CODE6=$?
set -e
assert_eq "1" "$CODE6" "Fetch failure should exit with code 1"
assert_contains "$OUT6" "Error: Failed to fetch latest upstream version" "Error message printed on fetch failure"

# Test 7: Update mode reporting when Nixpkgs Pi did not update
printf "\nTest 7: Update mode reporting when Nixpkgs Pi did not update\n"
set +e
OUT7=$(NIXPI_TEST_MOCK_NIX=1 NIXPI_TEST_CURRENT_VERSION="0.75.4" NIXPI_TEST_LATEST_VERSION="0.87.1" NIXPI_TEST_NEW_VERSION="0.75.4" "$UPDATER_SCRIPT" --update)
CODE7=$?
set -e
assert_eq "0" "$CODE7" "Update mode should exit 0 on success"
assert_contains "$OUT7" "Evaluation checks passed." "Evaluation checks distinguished and passed"
assert_contains "$OUT7" "Build verification passed." "Build verification distinguished and passed"
assert_contains "$OUT7" "Pi in Nixpkgs remains at 0.75.4 (upstream npm: 0.87.1 is not yet available in Nixpkgs)" "Truthful report when Pi did not update in Nixpkgs"

# Test 8: Update mode reporting when Nixpkgs Pi updated
printf "\nTest 8: Update mode reporting when Nixpkgs Pi updated\n"
set +e
OUT8=$(NIXPI_TEST_MOCK_NIX=1 NIXPI_TEST_CURRENT_VERSION="0.75.4" NIXPI_TEST_LATEST_VERSION="0.87.1" NIXPI_TEST_NEW_VERSION="0.87.1" "$UPDATER_SCRIPT" --update)
CODE8=$?
set -e
assert_eq "0" "$CODE8" "Update mode should exit 0 on success"
assert_contains "$OUT8" "Pi package updated in Nixpkgs: 0.75.4 -> 0.87.1" "Truthful report when Pi updated in Nixpkgs"

printf "\n=========================================\n"
printf "Summary: %d passed, %d failed\n" "$PASSED_COUNT" "$FAILED_COUNT"
printf "=========================================\n"

if [ "$FAILED_COUNT" -ne 0 ]; then
  exit 1
fi
