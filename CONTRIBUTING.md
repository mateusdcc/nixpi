# Contributing

Thank you for improving nixpi.

## Before opening a change

1. Check existing issues and pull requests for overlapping work.
2. Discuss public API changes before implementation.
3. Keep each change focused on one behavior or architectural concern.

## Local checks

Use a recent Nix installation with flakes enabled:

```console
nix fmt
nix flake check -L
nix flake check --all-systems --no-build -L
```

Add evaluation coverage for option changes, end-to-end coverage for runtime behavior, and real host integration coverage when Home Manager, NixOS, or nix-darwin behavior changes.

## Design rules

- Keep the public `programs.pi` schema shared across integrations.
- Put reusable behavior in `modules/core`, one capability per feature module, and composition in profiles.
- Preserve 1.x APIs with a deprecation warning and a tested compatibility alias.
- Keep secrets out of Nix expressions and generated store paths.
- Prefer direct Nix module composition over custom framework machinery.

## Commits and pull requests

Use Conventional Commits such as `fix(runtime): ...` or `docs: ...`. Each commit must be independently buildable and should contain one logical change. Pull requests should explain behavior, compatibility impact, and verification performed.
