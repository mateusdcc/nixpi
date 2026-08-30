# 2. Adoption of Nixvim Architectural Patterns and Composability

Date: 2026-08-26

## Status

Accepted

## Context

As `nixpi` evolved into a declarative framework for configuring the Pi coding agent, it became necessary to benchmark its architecture against mature, large-scale Nix configuration frameworks. Neovim's premier Nix framework, `nixvim` (with 450+ plugins, multi-platform integrations, and high composability), offers battle-tested design patterns for configuration management, module scaling, package distribution, and testing.

Key architectural gaps in early `nixpi` versions included:
1. **Lack of package composition**: Evaluating a Pi package via `makePi` returned an opaque derivation. Users could not easily inspect the evaluated `config`/`options` or extend an already-configured instance (`pkg.extend { ... }`).
2. **Boilerplate in module definitions**: Extensions and skills required repetitive option definitions (`enable`, `package`, `settings`, `runtimePackages`).
3. **Platform wrapper fragmentation**: Only Home Manager was integrated, with no native NixOS or nix-darwin system module wrappers.
4. **Flake output rigidity**: Flake exports were tied to specific naming conventions without standardized aliases or unified builder endpoints.

## Decision

We adopt the following architectural patterns from Nixvim into `nixpi`:

### 1. Package Distribution Strategy
- Nixpi separates declarative module abstractions from package definitions.
- Modules accept a `package` option defaulting to either the internal package or an upstream package, allowing users to override the underlying derivation cleanly.
- Direct escape hatches (`programs.pi.extraPackages`, `programs.pi.extraExtensions`, `programs.pi.extraSkills`) allow injecting arbitrary derivations without needing dedicated modules.

### 2. Standalone Package Composability (`passthru.extend`)
- `makePi` now wraps the resulting derivation with `passthru = { config, options, extend, unwrapped }`.
- Calling `pkg.extend { programs.pi.skills.commitStyle.enable = true; }` evaluates a new Pi package by appending the additional modules to the base configuration, mirroring Nixvim's `makeNixvim` composability.

### 3. Standardized Module Factories (`lib.mkPiExtensionModule` & `lib.mkPiSkillModule`)
- Introduce helper generators in `lib/module-factories.nix` that generate standardized module schemas:
  - `programs.pi.extensions.<name>.enable`
  - `programs.pi.extensions.<name>.package`
  - `programs.pi.extensions.<name>.settings`
  - `programs.pi.extensions.<name>.runtimePackages`
- Reduces code duplication across extension and skill definitions by ~70%.

### 4. Multi-Platform Module Unification (`integrations/`)
- Establish a shared evaluation engine (`integrations/shared.nix`) providing consistent options across:
  - **Standalone**: `lib.makePi` / `legacyPackages.${system}.makePiWithModule`
  - **Home Manager**: `homeModules.default` (with `homeManagerModules` preserved as a backwards-compatible alias)
  - **NixOS**: `nixosModules.default` and `nixosModules.pi`
  - **Nix-Darwin**: `nixDarwinModules.default` and `nixDarwinModules.pi`

### 5. Strict Backwards Compatibility & Graceful Deprecations
- All existing flake outputs (`piModules`, `homeManagerModules`, `packages.*`, `lib.*`) remain 100% functional.
- Any naming modernizations (e.g. `homeModules` over `homeManagerModules`) provide transparent compatibility layers and non-breaking warnings.

## Consequences

- Pre-configured Pi environments can be dynamically extended in devshells and downstream flakes using `.extend { ... }`.
- System-level configuration is now supported natively across Linux (NixOS) and macOS (nix-darwin).
- Authoring new extensions and skills requires significantly less boilerplate.
- Existing user configurations and test suites continue to work without any breaking changes.
