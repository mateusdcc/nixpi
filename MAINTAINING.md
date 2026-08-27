# Maintainer guide

## Release channels

- `main` is the stable channel.
- `edge` is the release candidate for the next stable update.
- Version tags use Semantic Versioning and the form `vMAJOR.MINOR.PATCH`.

The edge architecture is scheduled for promotion to `main` on September 3, 2026, after one week of public transition testing.

## Compatibility policy

Public flake outputs, module options, and library functions introduced in 1.x remain usable throughout 1.x. Renames and moves require:

1. A compatibility alias with an evaluation warning.
2. A direct replacement in the warning and migration guide.
3. Contract coverage for the old and new names.
4. Removal only in the next major release.

Security fixes may override this policy when preserving behavior would leave users exposed. Document the exception in the release notes.

## Release process

1. Confirm `edge` passes every required CI job.
2. Review deprecation warnings and the migration guide.
3. Build generated documentation with `nix build .#docs`.
4. Merge the tested edge release into `main` without unrelated changes.
5. Create an annotated version tag on the stable commit.
6. Push the tag. The release workflow validates the commit and publishes generated release notes.
7. Verify a fresh consumer can evaluate each supported host integration.

Do not edit generated release notes or generated option documentation in source. Fix their inputs instead.

## Supported systems

CI evaluates all declared systems and builds on x86_64 Linux, ARM Linux, Intel macOS, and Apple Silicon macOS. A system is supported only when its native CI job is required and passing.

Intel macOS uses the Nixpkgs 26.05 Darwin branch, which receives security fixes through the end of 2026. Reassess its support plan before that maintenance window closes.
