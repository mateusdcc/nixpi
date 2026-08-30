# Getting started

## Run the default package

```console
nix run github:mateusdcc/nixpi
```

The default package includes a declarative configuration with safe defaults. Pin the input in a flake for repeatable installations.

## Home Manager

Add the input and import the module:

```nix
{
  inputs.nixpi.url = "github:mateusdcc/nixpi";

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

Use `nixpi.nixosModules.default` in NixOS and `nixpi.nixDarwinModules.default` in nix-darwin. The `programs.pi` options are shared by every integration.

## Secrets

Do not put secret values in Nix expressions. Declare only their names with `programs.pi.environment.required`, then provide values through the runtime environment. The wrapper reports missing names before Pi starts.

## Updating safely

Commit `flake.lock`, review deprecation warnings, and run `nix flake check` before switching a system. Existing 1.x output names remain available with warnings throughout the 1.x release line.
