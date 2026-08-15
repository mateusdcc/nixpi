# 1. Mutable vs. Immutable State Separation

Date: 2026-08-15

## Status

Accepted

## Context

Pi Coding Agent manages both declarative resources (settings, packages, extensions, skills, prompt templates, themes, custom model definitions) and mutable runtime state:
- Session history (`sessions/` or `PI_CODING_AGENT_SESSION_DIR`)
- Authentication credentials and tokens (`auth.json`)
- Runtime lock files
- Debug log files (`pi-debug.log`)

When `PI_CODING_AGENT_DIR` is pointed directly to a read-only path in `/nix/store`, Pi attempts to call `writeFileSync` to ensure `auth.json` exists on startup and fails with `EACCES: permission denied`.

## Decision

1. Store declarative files (`settings.json`, `models.json`, packaged extensions, skills, themes, prompts) immutably in the Nix store.
2. In Home Manager mode, link `settings.json` and `models.json` into the user's mutable agent directory (`~/.pi/agent/` or `$XDG_CONFIG_HOME/pi/agent/`), leaving `auth.json` and `sessions/` writable by Pi.
3. In standalone and devShell wrapper mode, default mutable state to the user's standard home directory (`~/.pi/agent`) while instructing the wrapper to read declarative configuration from the generated store paths, and allow configuring `sessionDir` / `PI_CODING_AGENT_SESSION_DIR`.
4. Ensure no secret tokens or keys are written to `/nix/store`. Passwords and API keys remain external environment variables or are managed via `auth.json` / secret managers.

## Consequences

- Pi runs smoothly without permission errors.
- Declarative settings and extensions are 100% reproducible via Nix.
- Sessions and auth state persist normally without polluting the Nix store.
