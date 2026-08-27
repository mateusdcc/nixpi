# Templates

Initialize a new directory with the template that matches how Pi will be used:

```console
nix flake init --template github:mateusdcc/nixpi/edge#standalone
```

| Template | Command suffix | Use it for |
| --- | --- | --- |
| Standalone | `#standalone` | A configured `nix run .#` agent package. |
| Home Manager | `#home-manager` | A `home.nix` fragment for a user installation. |
| devShell | `#devshell` | A repository development environment, especially with direnv. |
| learning | `#learning` | Legacy compatibility only. Use deep-comprehension-engine for new learning environments. |

## Standalone

After initializing, set the target system and provider in `flake.nix`, export the required key, and run:

```console
nix run .#
```

## Home Manager

The template supplies a `home.nix` module. Add it to your Home Manager module list after importing `nixpi.homeModules.default`:

```nix
modules = [
  inputs.nixpi.homeModules.default
  ./home.nix
];
```

## devShell

Use this for a repository-specific agent and pair it with the [direnv guide](direnv.md). Enter it manually with:

```console
nix develop
```

The template makes Pi, Git, and ripgrep available in the shell. Change `programs.pi` in the template rather than maintaining a separate imperative setup script.
