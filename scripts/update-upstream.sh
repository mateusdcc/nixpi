#!/usr/bin/env bash
# scripts/update-upstream.sh
# Verifies and updates upstream dependencies for nixpi.
set -euo pipefail

PACKAGE_NAME="${PACKAGE_NAME:-@earendil-works/pi-coding-agent}"
NPM_REGISTRY_URL="${NPM_REGISTRY_URL:-https://registry.npmjs.org/${PACKAGE_NAME}/latest}"

usage() {
  cat << 'EOF'
Usage: ./scripts/update-upstream.sh [OPTIONS]

Options:
  -c, --check    Check upstream status without applying changes (exit 0 if up to date, 2 if update available)
  -u, --update   Update flake inputs, re-evaluate packaged version, and run evaluation + build verification
  -j, --json     Print status in JSON format
  -h, --help     Show this help message
EOF
}

fetch_latest_version() {
  if [ -n "${NIXPI_TEST_LATEST_VERSION:-}" ]; then
    echo "$NIXPI_TEST_LATEST_VERSION"
    return 0
  fi

  local version=""
  if command -v npm > /dev/null 2>&1; then
    version=$(npm view "$PACKAGE_NAME" version 2>/dev/null || true)
  fi

  if [ -z "$version" ]; then
    version=$(curl -sSfL "$NPM_REGISTRY_URL" 2>/dev/null | sed -n 's/.*"version":"\([^"]*\)".*/\1/p' || true)
  fi

  if [ -z "$version" ]; then
    return 1
  fi
  echo "$version"
}

get_current_version() {
  if [ -n "${NIXPI_TEST_CURRENT_VERSION:-}" ]; then
    echo "$NIXPI_TEST_CURRENT_VERSION"
    return 0
  fi

  if command -v nix > /dev/null 2>&1; then
    local v
    v=$(nix eval --raw .#pi-unwrapped.version 2>/dev/null || echo "")
    if [ -n "$v" ]; then
      echo "$v"
      return 0
    fi
  fi
  echo "unknown"
}

run_check() {
  local current="$1"
  local latest="$2"
  local json_mode="$3"

  local has_update="false"
  local status="up_to_date"
  if [ "$current" != "$latest" ] && [ -n "$latest" ]; then
    has_update="true"
    status="upstream_ahead"
  fi

  if [ "$json_mode" = "true" ]; then
    printf '{"package":"%s","current":"%s","packaged":"%s","latest":"%s","upstream":"%s","hasUpdate":%s,"hasUpstreamUpdate":%s,"upstreamAhead":%s,"status":"%s"}\n' \
      "$PACKAGE_NAME" "$current" "$current" "$latest" "$latest" "$has_update" "$has_update" "$has_update" "$status"
  else
    printf "Package: %s\n" "$PACKAGE_NAME"
    printf "Packaged Pi version: %s\n" "$current"
    printf "Upstream npm version: %s\n" "$latest"
    if [ "$has_update" = "true" ]; then
      printf "\nStatus: Upstream npm is ahead of Nixpkgs (npm: %s, Nixpkgs packaged: %s - not yet available in Nixpkgs)\n" "$latest" "$current"
    else
      printf "\nStatus: Up to date\n"
    fi
  fi

  if [ "$has_update" = "true" ]; then
    return 2
  fi
  return 0
}

run_update() {
  local prev_version="$1"
  local latest="$2"
  local json_mode="$3"

  printf "Updating nixpi dependencies...\n"
  printf "Current packaged Pi version: %s\n" "$prev_version"
  printf "Upstream npm version:        %s\n" "$latest"

  if [ "${NIXPI_TEST_MOCK_NIX:-0}" = "1" ]; then
    local new_version="${NIXPI_TEST_NEW_VERSION:-$prev_version}"
    printf "Updating flake inputs (mocked)...\n"
    printf "Running evaluation checks: nix flake check --all-systems --no-build -L (mocked)...\n"
    printf "Evaluation checks passed.\n"
    printf "Running build verification: nix flake check -L (mocked)...\n"
    printf "Build verification passed.\n"
  elif command -v nix > /dev/null 2>&1; then
    printf "Updating flake inputs...\n"
    nix flake update

    local new_version
    new_version="$(get_current_version)"

    printf "Running evaluation checks (nix flake check --all-systems --no-build -L)...\n"
    nix flake check --all-systems --no-build -L
    printf "Evaluation checks passed.\n"

    printf "Running build verification (nix flake check -L)...\n"
    nix flake check -L
    printf "Build verification passed.\n"
  else
    printf "Error: 'nix' command is not available.\n" >&2
    exit 1
  fi

  local pi_updated="false"
  if [ "$new_version" != "$prev_version" ]; then
    pi_updated="true"
  fi

  if [ "$json_mode" = "true" ]; then
    printf '{"package":"%s","prevPackaged":"%s","newPackaged":"%s","upstream":"%s","piUpdated":%s}\n' \
      "$PACKAGE_NAME" "$prev_version" "$new_version" "$latest" "$pi_updated"
  else
    if [ "$pi_updated" = "true" ]; then
      printf "\nPi package updated in Nixpkgs: %s -> %s\n" "$prev_version" "$new_version"
    elif [ "$new_version" != "$latest" ]; then
      printf "\nFlake inputs updated, but Pi in Nixpkgs remains at %s (upstream npm: %s is not yet available in Nixpkgs).\n" "$new_version" "$latest"
    else
      printf "\nFlake inputs updated. Pi is up to date with upstream (%s).\n" "$new_version"
    fi
    printf "All checks passed successfully.\n"
  fi
}

main() {
  local mode="check"
  local json_mode="false"

  while [ $# -gt 0 ]; do
    case "$1" in
      -c|--check)
        mode="check"
        shift
        ;;
      -u|--update)
        mode="update"
        shift
        ;;
      -j|--json)
        json_mode="true"
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        printf "Error: Unknown option: %s\n" "$1" >&2
        usage >&2
        exit 1
        ;;
    esac
  done

  local current
  local latest
  current="$(get_current_version)"
  if ! latest="$(fetch_latest_version)"; then
    printf "Error: Failed to fetch latest upstream version for %s\n" "$PACKAGE_NAME" >&2
    exit 1
  fi

  if [ "$mode" = "check" ]; then
    run_check "$current" "$latest" "$json_mode"
  elif [ "$mode" = "update" ]; then
    run_update "$current" "$latest" "$json_mode"
  fi
}

main "$@"
