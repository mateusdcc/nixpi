# direnv

`direnv` is a convenient way to give a repository a reproducible Pi command and expose secret names only while you are in that repository.

## Project flake

Start with the `devshell` template or add this output to an existing flake:

```nix
devShells.${system}.default = pkgs.mkShell {
  packages = [
    (nixpi.lib.nixpi.makePi {
      inherit pkgs;
      modules = [{
        programs.pi = {
          enable = true;
          settings.defaultProvider = "openai";
          extensions.ripgrep-search.enable = true;
          environment.required = [ "OPENAI_API_KEY" ];
        };
      }];
    })
  ];
};
```

## `.envrc`

Keep secrets outside Git. One simple pattern is a local `.envrc` that reads a separately ignored file and enters the flake development shell:

```sh
dotenv_if_exists .env.local
use flake
```

Put the real value in `.env.local`, which must be ignored:

```sh
export OPENAI_API_KEY='replace-with-your-secret-manager-output'
```

Then allow the project once:

```console
direnv allow
pi
```

## Why this works

`use flake` adds the configured Pi package to `PATH`. nixpi evaluates the required variable names into the launcher but does not evaluate their values. The launcher verifies that `OPENAI_API_KEY` is present only when you start Pi.

For shared or production credentials, have `.envrc` call your existing secret manager instead of storing a value in `.env.local`.
