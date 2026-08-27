# Flake outputs

| Output | Purpose |
| --- | --- |
| `packages.<system>.default` | Configured Pi executable |
| `packages.<system>.legal-research` | Legal research profile |
| `packages.<system>.docs` | Generated option and project documentation |
| `piModules.default` | Complete standalone module |
| `piModules.base` | Reusable core without bundled features |
| `piModules.profiles.*` | Curated configurations |
| `piModules.extensions.*` | Individual extension modules |
| `piModules.skills.*` | Individual skill modules |
| `piModules.providers.*` | Individual provider modules |
| `homeModules.default` | Home Manager integration |
| `nixosModules.default` | NixOS integration |
| `nixDarwinModules.default` | nix-darwin integration |
| `lib.nixpi` | Canonical library namespace |
| `overlays.default` | Adds packages under `pkgs.nixpi` |
| `templates.*` | Starter flakes |

Compatibility aliases such as `homeManagerModules`, `piModules.core`, and moved learning resources remain available during 1.x. Evaluation emits a warning that identifies the replacement.

The complete generated option reference is available from:

```console
nix build .#docs
```

Open `result/share/doc/nixpi/options.md` after the build.
