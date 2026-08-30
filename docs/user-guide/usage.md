# Everyday usage

## Choose an integration

Use the same `programs.pi` options in every integration. The difference is where the evaluated package is installed.

| Situation | Entry point | Run it |
| --- | --- | --- |
| One-off trial | `packages.<system>.default` | `nix run github:mateusdcc/nixpi` |
| Project-owned agent | `lib.nixpi.makePi` | `nix run .#` |
| User environment | `homeModules.default` | activate Home Manager |
| NixOS host | `nixosModules.default` | rebuild NixOS |
| macOS host | `nixDarwinModules.default` | rebuild nix-darwin |

## Standalone package

This is the smallest persistent configuration. Put it in a project `flake.nix`, replace the system value when needed, and keep `flake.lock` committed.

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05";
    nixpi.url = "github:mateusdcc/nixpi";
  };

  outputs = { nixpkgs, nixpi, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system}.default = nixpi.lib.nixpi.makePi {
        inherit pkgs;
        modules = [{
          programs.pi = {
            enable = true;
            settings = {
              defaultProvider = "openai";
              defaultModel = "gpt-4o";
            };
            extensions.ripgrep-search.enable = true;
            skills.commit-style.enable = true;
            environment.required = [ "OPENAI_API_KEY" ];
          };
        }];
      };
    };
}
```

Run it with `nix run .#`. `environment.required` checks that a name exists at launch time. It does not put secret values in the Nix store.

## Using `pi-packages` for Extended Extensions & Skills

For advanced capabilities like multi-agent swarms (`subagents`), on-demand architecture diagramming (`lazy-archify`), clipboard image tools (`image-tools`), and native macOS screenshotting (`app-screenshot`), add the companion [**`pi-packages`**](https://github.com/mateusdcc/pi-packages) flake:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpi.url = "github:mateusdcc/nixpi";
    pi-packages = {
      url = "github:mateusdcc/pi-packages";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpi.follows = "nixpi";
    };
  };

  outputs = { nixpkgs, nixpi, pi-packages, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system}.default = nixpi.lib.makePi {
        inherit pkgs;
        modules = [
          pi-packages.piModules.default
          {
            programs.pi = {
              extensions = {
                subagents.enable = true;
                lazy-archify.enable = true;
                image-tools.enable = true;
                app-screenshot.enable = true;
              };
              skills = {
                commit-style.enable = true;
                generative-ui.enable = true;
              };
            };
          }
        ];
      };
    };
}
```

## Home Manager

Import `nixpi.homeModules.default`, then configure the same module namespace:

```nix
{
  imports = [
    inputs.nixpi.homeModules.default
    inputs.pi-packages.homeModules.default
  ];

  programs.pi = {
    enable = true;
    settings.defaultProvider = "anthropic";
    extensions.plan-mode = {
      enable = true;
      mode = "balanced";
    };
    extensions.subagents.enable = true;
    environment.required = [ "ANTHROPIC_API_KEY" ];
  };
}
```

The integration installs the evaluated package and links the generated immutable `settings.json` and, when configured, `models.json` under `~/.pi/agent`.

## NixOS and nix-darwin

Import `inputs.nixpi.nixosModules.default` in NixOS or `inputs.nixpi.nixDarwinModules.default` in nix-darwin. Configure `programs.pi` exactly as above. The option schema and generated package are shared across all three host integrations.

## Secrets and state

Put only non-secret values in `environment.variables`. Export API keys from your shell, your secret manager, or your host configuration before starting Pi. `auth.json` and `sessions/` remain mutable runtime state.

```nix
programs.pi.environment = {
  variables.PI_OFFLINE = "1";
  required = [ "OPENAI_API_KEY" ];
};
```

Do not write API key values into a Nix expression. Nix derivations and their logs can be world-readable to users of the same store.
