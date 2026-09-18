#!/usr/bin/env bash
# scripts/update-upstream.sh
# Verifies and updates upstream dependencies for nixpi.
set -euo pipefail

PACKAGE_NAME="@earendil-works/pi-coding-agent"
NPM_REGISTRY_URL="https://registry.npmjs.org/${PACKAGE_NAME}/latest"

usage() {
  cat << 'EOF'
Usage: ./scripts/update-upstream.sh [OPTIONS]

Options:
  -c, --check    Check if upstream has updates without applying changes (exit 2 if outdated)
  -u, --update   Update dependencies, update flake lock, and run tests
  -j, --json     Print status in JSON format
  -h, --help     Show this help message
EOF
}

fetch_latest_version() {
  if command -v npm > /dev/null 2>&1; then
    npm view "$PACKAGE_NAME" version 2>/dev/null || true
  else
    curl -sSfL "$NPM_REGISTRY_URL" | sed -n 's/.*"version":"\([^"]*\)".*/\1/p' || true
  fi
}

get_current_version() {
  if command -v nix > /dev/null 2>&1; then
    nix eval --raw .#pi-unwrapped.version 2>/dev/null || echo "unknown"
  else
    echo "unknown"
  fi
}

run_check() {
  local current="$1"
  local latest="$2"
  local json_mode="$3"

  local has_update="false"
  if [ "$current" != "$latest" ] && [ -n "$latest" ]; then
    has_update="true"
  fi

  if [ "$json_mode" = "true" ]; then
    printf '{"package":"%s","current":"%s","latest":"%s","hasUpdate":%s}\n' \
      "$PACKAGE_NAME" "$current" "$latest" "$has_update"
  else
    printf "Package: %s\n" "$PACKAGE_NAME"
    printf "Current version: %s\n" "$current"
    printf "Latest version:  %s\n" "$latest"
    if [ "$has_update" = "true" ]; then
      printf "\nStatus: Update available (%s -> %s)\n" "$current" "$latest"
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
  local current="$1"
  local latest="$2"

  printf "Updating nixpi dependencies...\n"
  printf "Upstream version: %s -> %s\n" "$current" "$latest"

  if command -v nix > /dev/null 2>&1; then
    printf "Updating flake inputs...\n"
    nix flake update

    printf "Running flake checks...\n"
    nix flake check --no-build
    printf "\nAll checks passed successfully.\n"
  else
    printf "Error: 'nix' command is not available.\n" >&2
    exit 1
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
        printf "Unknown option: %s\n" "$1" >&2
        usage
        exit 1
        ;;
    esac
  done

  local current
  local latest
  current="$(get_current_version)"
  latest="$(fetch_latest_version)"

  if [ -z "$latest" ]; then
    printf "Error: Failed to fetch latest upstream version for %s\n" "$PACKAGE_NAME" >&2
    exit 1
  fi

  if [ "$mode" = "check" ]; then
    run_check "$current" "$latest" "$json_mode"
  elif [ "$mode" = "update" ]; then
    run_update "$current" "$latest"
  fi
}

main "$@"
