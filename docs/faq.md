# FAQ

## Why are there files in both `~/.pi/agent` and `$XDG_DATA_HOME/nixpi/agent`?

This is the concern raised in [issue #3](https://github.com/mateusdcc/nixpi/issues/3). It is not a configuration split. Home Manager links generated `settings.json` and `models.json` under `~/.pi/agent`. The generated launcher sets `PI_CODING_AGENT_DIR` to its XDG runtime directory and links the same immutable generated configuration there before Pi starts.

Pi reads the directory selected by the launcher. The Home Manager links are useful as a conventional, inspectable location, but they are not a competing configuration source. `auth.json` and `sessions/` remain writable runtime state.

## Where should API keys go?

Outside Nix expressions. Export them from your shell, direnv, a secret manager, or host secret integration, then list only the variable names in `programs.pi.environment.required`. See [direnv](user-guide/direnv.md).

## Why does `nix build` not show my new secret or session?

Those values are intentionally not build inputs. nixpi produces immutable configuration and a launcher. Credentials and session state are runtime data, so they are neither copied into the Nix store nor changed by rebuilds.

## Which branch should I pin?

Pin `main` for the stable release channel or track specific version tags like `v1.0.0`. Pin the input deliberately in your `flake.nix`, commit `flake.lock`, and read warnings when updating. Use the versioned compatibility policy in the README and [migration guide](migrations/edge.md) when moving older configurations.

## How do I see every available option?

Open [All options](reference/options.md) on this site. It is generated with `nixosOptionsDoc` from the evaluated `programs.pi` schema. Locally, run `nix build .#docs` and open `result/share/doc/nixpi/options.md`.

## Can I use nixpi without Home Manager, NixOS, or nix-darwin?

Yes. Use `lib.nixpi.makePi` in a standalone flake, or initialize the [standalone template](user-guide/templates.md). Run the resulting package with `nix run .#`.

## How do I add an extension or skill that nixpi does not package?

Package it with `mkPiExtension` or `mkPiSkill`, then compose an option module with `mkPiExtensionModule` or `mkPiSkillModule`. The [Library API](reference/library.md) includes each function signature and example.

## Why did I get a deprecation warning?

The output or option is a supported 1.x compatibility alias. The warning names its replacement. Update to that replacement before the next major version, then run `nix flake check` to validate the migrated configuration.
