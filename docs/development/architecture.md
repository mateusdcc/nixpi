# Architecture

nixpi separates stable contracts from implementation details.

## Layers

1. `lib/` evaluates modules, builds packages, defines resource constructors, and owns deprecation helpers.
2. `modules/core/` defines the reusable `programs.pi` schema and package assembly.
3. `modules/extensions/`, `modules/skills/`, and `modules/providers/` add one capability each.
4. `modules/profiles/` composes capabilities into opinionated configurations.
5. `integrations/` maps the shared module into Home Manager, NixOS, and nix-darwin.
6. `flake/` publishes modules, packages, templates, checks, and legacy builders.

The root `flake.nix` only composes these output families. This keeps public contracts visible while preventing one file from owning unrelated concerns.

## Dependency direction

Feature modules may depend on core options. Profiles may depend on feature modules. Integrations may depend on the complete module. Core modules must not depend on profiles or integrations.

## Compatibility

Renames use helpers from `lib/deprecation.nix`. A deprecated output must continue to evaluate, identify its replacement, and have contract coverage. Breaking removals are reserved for a major release.

## Verification

Unit-style evaluation tests cover option behavior. End-to-end tests execute the wrapped binary. Integration tests evaluate the project inside the real Home Manager, NixOS, and nix-darwin module systems. CI evaluates every supported system and builds on each platform family.
