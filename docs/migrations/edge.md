# Migrating to the edge architecture

The edge release reorganizes internals while preserving the 1.x public contract.

## Recommended names

- Use `lib.nixpi` for library helpers.
- Use `piModules.base` for the complete reusable core.
- Use `homeModules.default`, `nixosModules.default`, or `nixDarwinModules.default` for host integration.
- Import learning and Obsidian resources directly from `deep-comprehension-engine` in new configurations.

## Compatibility aliases

The previous helper names, `piModules.core`, `homeManagerModules`, learning profile, Obsidian extension, and moved learning skill packages remain available throughout 1.x. They emit evaluation warnings but preserve behavior.

## Rollout checklist

1. Update the nixpi input on a feature branch.
2. Run `nix flake check` in the consuming configuration.
3. Replace warned names with their documented replacements.
4. Build the target Home Manager, NixOS, or nix-darwin configuration without activating it.
5. Commit the updated lock file before activation.

Runtime secrets stay outside the Nix store. If `environment.required` is used, make sure those variables exist in the activation environment before starting Pi.
