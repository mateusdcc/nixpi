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
| `extensions` | Enable prepackaged extensions and configure settings. |
| `customExtensions` | Declarative custom extensions (inline code, entrypoint, or source directory). |
| `skills` | Enable prepackaged skill packages. |
| `customSkills` | Declarative custom skills (inline Markdown or directory). |
| `customPrompts` | Declarative custom prompt templates. |
| `customThemes` | Declarative custom color themes. |
| `prompts` and `themes` | Add prompt and theme resources. |
| `runtimePackages` | Commands available to Pi and extensions at runtime. |
| `environment` | Non-secret variables and required environment variable names. |
| `resources` and `extraPackages` | Compose custom resource and package inputs. |

## Declarative custom resources

Declare custom extensions, skills, prompts, and themes directly in your configuration without boilerplate:

```nix
programs.pi = {
  enable = true;

  # Custom extensions
  customExtensions = {
    # 1. Inline Javascript / Typescript
    git-status = {
      enable = true;
      version = "1.0.0";
      runtimePackages = [ pkgs.git ];
      content = ''
        export default function(pi) {
          pi.registerCommand("git-status", {
            description: "Show short git status",
            handler: async (args, ctx) => {
              const { execSync } = require("child_process");
              console.log(execSync("git status -s", { encoding: "utf-8" }));
            }
          });
        }
      '';
    };

    # 2. Single file entrypoint
    theme-picker = {
      enable = true;
      entrypoint = ./scripts/theme-picker.js;
      runtimePackages = [ pkgs.jq ];
    };

    # 3. Source directory
    advanced-analyzer = {
      enable = true;
      src = ./my-extension-dir;
      runtimePackages = [ pkgs.ripgrep pkgs.fd ];
    };
  };

  # Custom skills
  customSkills.code-reviewer = {
    enable = true;
    description = "Perform rigorous code review";
    content = ''
      # Code Review Skill
      Analyze code for architectural cleanliness and potential bugs.
    '';
  };

  # Custom prompts
  customPrompts.refactor = {
    enable = true;
    description = "Refactor selected code";
    argumentHint = "[function-name]";
    content = "Please refactor the following function to follow Clean Code: $ARGUMENTS";
  };

  # Custom themes
  customThemes.neon-dark = {
    enable = true;
    colors = {
      accent = "#00ffcc";
      background = "#0d1117";
    };
  };
};
```

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
