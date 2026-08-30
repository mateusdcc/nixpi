# Security policy

## Reporting a vulnerability

Use GitHub private vulnerability reporting for the repository. Do not open a public issue for suspected credential exposure, arbitrary code execution, unsafe generated shell, or a dependency vulnerability with a known exploit.

Include the affected revision, configuration, reproduction steps, impact, and any known mitigation. Maintainers should acknowledge a complete report within three business days and coordinate disclosure after a fix is available.

## Supported versions

The latest stable release and the current `edge` release candidate receive security fixes. Older revisions may receive a backport when upgrading immediately would create a larger operational risk.

## Security boundaries

nixpi generates packages, configuration files, and a runtime wrapper. Secret values must be supplied at runtime and must not be committed to Nix expressions, lock files, build logs, or store paths. Report any behavior that serializes secret values into the Nix store.
