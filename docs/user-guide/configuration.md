# Configuration

All configuration lives under `programs.pi`. This page provides a map; use [All options](../reference/options.md) for the generated, exhaustive reference.

```nix
programs.pi = {
  enable = true;

  settings = {
    defaultProvider = "openai";
    defaultModel = "gpt-4o";
    defaultThinkingLevel = "medium";
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
    models = [{ id = "local-model"; }];
  };

  runtimePackages = with pkgs; [ git jq ];
  environment.required = [ "OPENAI_API_KEY" ];
};
```

## Main sections

| Section | Purpose |
| --- | --- |
| `settings` | Pi settings serialized into the generated settings file. |
| `providers` | Provider endpoints, package support, models, and credentials references. |
| `extensions` | Enable packaged extensions and provide extension-specific settings. |
| `skills` | Enable skill packages that Pi can discover. |
| `prompts` and `themes` | Add prompt and theme resources. |
| `runtimePackages` | Commands available to Pi and extensions at runtime. |
| `environment` | Non-secret variables and required environment variable names. |
| `resources` and `extraPackages` | Compose custom resource and package inputs. |

## Add a local provider

```nix
programs.pi.providers.local = {
  baseUrl = "http://localhost:11434/v1";
  api = "openai-completions";
  models = [
    {
      id = "qwen2.5-coder";
      name = "Qwen 2.5 Coder";
    }
  ];
};
```

## Add runtime tools

An extension that invokes `git`, `rg`, or a language runtime needs those executables in `runtimePackages`:

```nix
programs.pi.runtimePackages = with pkgs; [
  git
  ripgrep
  jq
  nodejs
];
```

The generated option reference documents the exact option type and default for each item.
