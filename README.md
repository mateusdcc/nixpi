# nixpi

Declarative Nix configuration for the [Pi coding agent](https://github.com/badlogic/pi-mono), with typed modules, packaged extensions and skills, reusable profiles, and host integrations.

> [!NOTE]
> This branch is the edge release candidate. It preserves the 1.x public contract while testing the architecture planned for `main`.

## Why nixpi

- One `programs.pi` schema for standalone packages, Home Manager, NixOS, and nix-darwin.
- Reproducible settings, providers, extensions, skills, prompts, themes, and runtime dependencies.
- Secret-safe configuration that stores variable names, not secret values.
- Compatibility aliases and evaluation warnings for moved 1.x APIs.
- Real host-module integration tests and cross-platform CI.

## Quick start

Run the default configuration directly:

```console
nix run github:mateusdcc/nixpi/edge
```

For a persistent configuration, add nixpi to your flake and import the host module:

```nix
{
  inputs.nixpi.url = "github:mateusdcc/nixpi/edge";

  outputs = { home-manager, nixpkgs, nixpi, ... }: {
    homeConfigurations.me = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      modules = [
        nixpi.homeModules.default
        {
          home = {
            username = "me";
            homeDirectory = "/Users/me";
            stateVersion = "26.05";
          };

          programs.pi = {
            enable = true;
            settings.defaultProvider = "openai";
            extensions.ripgrep-search.enable = true;
            skills.commit-style.enable = true;
            environment.required = [ "OPENAI_API_KEY" ];
          };
        }
      ];
    };
  };
}
```

Use `nixosModules.default` for NixOS or `nixDarwinModules.default` for nix-darwin. All integrations expose the same `programs.pi` options.

## Common configuration

```nix
programs.pi = {
  enable = true;

  settings = {
    defaultProvider = "anthropic";
    theme = "dark";
  };

  extensions = {
    echo.enable = true;
    ripgrep-search.enable = true;
    plan-mode.enable = true;
  };

  skills.commit-style.enable = true;

  providers.local = {
    baseUrl = "http://localhost:11434/v1";
    models = [ { id = "local-model"; } ];
  };

  environment = {
    variables.PI_OFFLINE = "1";
    required = [ "ANTHROPIC_API_KEY" ];
  };
};
```

Never put API keys in `environment.variables` or another Nix expression. Provide secret values through the runtime environment. nixpi checks required names before Pi starts.

## Public API

The canonical entry points are:

- `lib.nixpi` for package builders, resource constructors, module factories, and deprecation helpers.
- `piModules.base` for the reusable core and `piModules.default` for the bundled module set.
- `piModules.profiles.*`, `piModules.extensions.*`, `piModules.skills.*`, and `piModules.providers.*` for composition.
- `homeModules.default`, `nixosModules.default`, and `nixDarwinModules.default` for host integration.
- `overlays.default` for packages under `pkgs.nixpi`.

See the [flake output reference](docs/reference/flake-outputs.md) for the complete map.

## Compatibility policy

Existing 1.x output names remain available throughout the 1.x line. Renamed and moved APIs emit warnings with direct replacements. Breaking removals require a major release and a migration guide.

Users should commit `flake.lock`, review warnings during updates, and build their target configuration before activation. See the [edge migration guide](docs/migrations/edge.md).

## Documentation

- [Documentation website](https://mateusdcc.github.io/nixpi/)
- [Getting started](docs/user-guide/getting-started.md)
- [Usage and direnv](docs/user-guide/usage.md)
- [Templates](docs/user-guide/templates.md)
- [Library API](docs/reference/library.md)
- [Generated option reference](docs/reference/options.md)
- [FAQ](docs/faq.md)

Build the complete documentation bundle, including options generated from the live module schema:

```console
nix build .#docs
```

The result is written to `result/share/doc/nixpi`.

## Development

```console
nix fmt
nix flake check -L
nix flake check --all-systems --no-build -L
```

CI performs all-system evaluation and native builds on x86_64 Linux, ARM Linux, Intel macOS, and Apple Silicon macOS. Tagged versions matching `v*` are validated before a GitHub release is published.

See [CONTRIBUTING.md](CONTRIBUTING.md) before proposing a change, [SECURITY.md](SECURITY.md) for private vulnerability reporting, and [MAINTAINING.md](MAINTAINING.md) for compatibility and release policy.
