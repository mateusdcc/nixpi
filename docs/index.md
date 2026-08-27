# nixpi

nixpi declaratively configures the [Pi coding agent](https://github.com/badlogic/pi-mono) with Nix. It provides one typed `programs.pi` module for standalone packages, Home Manager, NixOS, and nix-darwin.

> This site documents the `edge` branch. It is the 1.x release candidate and preserves the public contract while the next architecture is exercised.

## Start here

Run the default agent without creating a configuration:

```console
nix run github:mateusdcc/nixpi/edge
```

For a project or personal configuration, start from a [template](user-guide/templates.md), then read the [usage guide](user-guide/usage.md). The [complete option reference](reference/options.md) is generated from the live Nix module schema during every documentation build, so it includes every `programs.pi` option, type, default, and description.

## What is documented

- Every public flake output and library function, with callable examples.
- Every `programs.pi` option, generated from the evaluated module.
- Bundled profiles, extensions, skills, and providers.
- Home Manager, NixOS, nix-darwin, standalone, devShell, and direnv usage.
- Templates, secrets, mutable state, updating, tests, migration guidance, and troubleshooting.

The site is built by `nix build .#docs`. Its static files are in `result/share/doc/nixpi/html` and GitHub Actions publishes that same directory to GitHub Pages.
