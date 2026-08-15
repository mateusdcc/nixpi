# nixpi

> Nix-native declarative configuration framework for the [Pi coding agent](https://pi.dev).

`nixpi` provides a typed, declarative, reproducible configuration framework for the Pi coding agent, inspired by the architecture of projects like Nixvim.

---

## Table of Contents

- [What nixpi is](#what-nixpi-is)
- [What nixpi is NOT](#what-nixpi-is-not)
- [Quick Start (Standalone)](#quick-start-standalone)
- [Home Manager Integration](#home-manager-integration)
- [Development Shell (`nix develop`)](#development-shell-nix-develop)
- [Managing Extensions](#managing-extensions)
- [Managing Skills (e.g. Conventional Commits)](#managing-skills-eg-conventional-commits)
- [Automatic Runtime Dependencies](#automatic-runtime-dependencies)
- [Custom Providers (e.g. Antigravity)](#custom-providers-eg-antigravity)
- [Secret Safety](#secret-safety)
- [Mutable vs. Immutable State Separation](#mutable-vs-immutable-state-separation)
- [Extension Authoring Guide](#extension-authoring-guide)
- [Flake Outputs & Public APIs](#flake-outputs--public-apis)
- [Testing & Verification](#testing--verification)

---

## What nixpi is

`nixpi` is a Nix framework that allows you to define your entire Pi setup declaratively:
- Settings (`settings.json`)
- Custom provider & model registries (`models.json`)
- Packaged extensions & their Node/CLI dependencies
- Skills, prompt templates, and themes
- Non-secret environment variables and runtime requirements

```text
Nix / nixpi:
    package acquisition
    pinning
    reproducibility
    dependency composition
    typed configuration
    validation
    runtime dependency construction
    configuration generation

Pi:
    extension loading
    tools
    commands
    lifecycle events
    sessions
    providers
    model execution
    TUI
```

---

## What nixpi is NOT

- **NOT a replacement package manager**: `nixpi` does not implement `nixpi install` or a custom mutable package database.
- **NOT an extension runtime**: Pi itself executes extensions, tools, commands, and prompts using its standard interfaces.
- **NOT a secret store**: `nixpi` does not store API keys or private tokens in the Nix store.

---

## Quick Start (Standalone)

Create a standalone configured Pi package without modifying your global environment:

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpi.url = "github:mateusdcc/nixpi";
  };

  outputs = { self, nixpkgs, nixpi }:
    let
      system = "aarch64-darwin"; # or "x86_64-linux", etc.
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system}.default = nixpi.lib.makePi {
        inherit pkgs;
        modules = [
          {
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
              };

              runtimePackages = with pkgs; [
                git
                jq
              ];
            };
          }
        ];
      };
    };
}
```

Run it directly with:

```bash
nix run .#default
```

---

## Home Manager Integration

Import `nixpi.homeManagerModules.default` into your Home Manager configuration:

```nix
# home.nix
{ pkgs, ... }:

{
  programs.pi = {
    enable = true;

    settings = {
      defaultProvider = "openai";
      defaultModel = "gpt-4o";
      defaultThinkingLevel = "medium";
      theme = "dark";
      compaction = {
        enabled = true;
        reserveTokens = 16384;
      };
    };

    extensions = {
      echo.enable = true;
      ripgrep-search.enable = true;
      plan-mode = {
        enable = true;
        mode = "balanced";
        maxSteps = 15;
      };
    };

    runtimePackages = with pkgs; [
      git
      ripgrep
      jq
      fd
    ];

    environment = {
      required = [
        "OPENAI_API_KEY"
      ];
    };
  };
}
```

This installs the configured `pi` binary and links immutable `settings.json` and `models.json` into `~/.pi/agent/`, while keeping `auth.json` and `sessions/` writable in place.

---

## Development Shell (`nix develop`)

Configure project-specific Pi environments alongside your compilers and linters:

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpi.url = "github:mateusdcc/nixpi";
  };

  outputs = { self, nixpkgs, nixpi }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};

      projectPi = nixpi.lib.makePi {
        inherit pkgs;
        modules = [
          {
            programs.pi = {
              enable = true;
              settings.defaultProvider = "openai";
              extensions.ripgrep-search.enable = true;
            };
          }
        ];
      };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          projectPi
          pkgs.git
          pkgs.nodejs
        ];
      };
    };
}
```

When you enter `nix develop`, running `pi` uses the project's pinned configuration.

---

## Managing Extensions

Extensions in `nixpi` are first-class Nix modules:

```nix
programs.pi.extensions = {
  # Enable built-in extension modules with typed configuration
  plan-mode = {
    enable = true;
    mode = "thorough"; # Checked at eval time: "fast" | "balanced" | "thorough"
    maxSteps = 20;
    autoApprove = false;
  };

  ripgrep-search.enable = true;
};
```

---

## Managing Skills (e.g. Conventional Commits)

Skills teach Pi procedural workflows, domain specifications, and coding guidelines.

### 1. Enable Built-in Skills (e.g. `commit-style`)

`nixpi` provides a 100% Nix-configured `commit-style` skill based on the [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/#specification) specification:

```nix
programs.pi.skills.commit-style = {
  enable = true;
  # Optional customizations configured entirely in Nix:
  scopes = [ "api" "auth" "cli" "core" "docs" "ui" ];
  customGuidelines = [
    "Always make minimal, atomic single-intent commits."
    "Keep commit summary lines under 72 characters."
  ];
};
```

When enabled, `commit-style` automatically provides the full Conventional Commits specification rules, structural formatting (`<type>[optional scope]: <description>`), imperative tense rules, breaking change indicators (`!` and `BREAKING CHANGE:`), and concrete examples (e.g. `fix(api): prevent null pointer on missing ID`) to Pi.

### 2. Declare Custom Skills via `mkPiSkill`

You can also construct custom skills entirely in Nix:

```nix
programs.pi.rawSkills = [
  (nixpi.lib.mkPiSkill {
    name = "clean-code-review";
    description = "Instructions for reviewing code according to Clean Code standards";
    content = ''
      # Clean Code Review Runbook
      - Verify Single Responsibility Principle (SRP).
      - Check that functions aim for < 10 lines.
      - Ensure zero dead code and high cohesion.
    '';
    runtimePackages = [ pkgs.git ];
  })
];
```

---

## Automatic Runtime Dependencies

When an extension requires external CLI tools (like `rg`, `git`, or `jq`), enabling the extension automatically pulls those packages into the wrapped `pi` environment's `PATH`.

You do not need to manually install or manage them globally.

---

## Custom Providers & Antigravity

`nixpi` models providers and models as first-class Nix objects with schema validation. Instead of passing unverified strings, `settings.defaultProvider` and `settings.defaultModel` directly accept provider and model objects (e.g. `config.programs.pi.providers.antigravity` and `config.programs.pi.providers.antigravity.models."gemini-3.7-flash"`), ensuring that providers and models are declared and exist at evaluation time.

### 1. Antigravity Provider (`pi-antigravity`)

`nixpi` includes native support for [`pi-antigravity`](https://github.com/Rahularya01/pi-antigravity), providing Google Cloud Code Assist / Antigravity OAuth login and streaming:

```nix
{ config, ... }:

{
  programs.pi = {
    enable = true;

    # Enable Antigravity provider
    providers.antigravity.enable = true;

    settings = {
      # Reference the provider and model objects directly
      defaultProvider = config.programs.pi.providers.antigravity;
      defaultModel = config.programs.pi.providers.antigravity.models."gemini-3.7-flash";
    };
  };
}
```

After starting Pi, run `/login antigravity` to authenticate with Google OAuth.


### 2. Custom Providers via `mkPiProvider`

Construct custom provider objects with static endpoints or package derivations using `nixpi.lib.mkPiProvider`:

```nix
programs.pi = {
  enable = true;

  providers.ollama-local = nixpi.lib.mkPiProvider {
    name = "ollama-local";
    baseUrl = "http://127.0.0.1:11434/v1";
    api = "openai-completions";
    models = [
      {
        id = "llama3.3";
        name = "Llama 3.3 70B";
        contextWindow = 131072;
      }
    ];
  };

  settings.defaultProvider = "ollama-local";
};
```

---


## Secret Safety

> **CRITICAL RULE**: Never put secret API keys, OAuth tokens, or passwords directly in your Nix expressions.

Everything in a Nix configuration becomes world-readable in `/nix/store`.

`nixpi` supports declaring **secret requirements**:

```nix
programs.pi.environment.required = [
  "ANTHROPIC_API_KEY"
  "OPENAI_API_KEY"
];
```

Provide the actual values via standard runtime secret managers:
- Environment variables (`export OPENAI_API_KEY=...`)
- `sops-nix` or `agenix`
- macOS Keychain / 1Password CLI
- Pi's interactive `/login` command (persists to `auth.json`)

---

## Mutable vs. Immutable State Separation

Pi separates declarative configuration from runtime state:

- **Immutable (Nix-managed)**: `settings.json`, `models.json`, packaged extensions, skills, prompts, themes.
- **Mutable (Pi-managed)**: `sessions/`, `auth.json`, `pi-debug.log`.

`nixpi` ensures that Pi's runtime directory remains writable while referencing the immutable Nix store artifacts, avoiding permission errors on startup.

---

## Extension Authoring Guide

### 1. Package the Extension (`default.nix`)

```nix
{ pkgs, mkPiExtension }:

mkPiExtension {
  pname = "git-summary";
  version = "1.0.0";
  runtimePackages = [ pkgs.git pkgs.jq ];

  src = pkgs.writeTextDir "extensions/index.js" ''
    import { execSync } from "node:child_process";

    export default function(pi) {
      if (pi && pi.registerCommand) {
        pi.registerCommand("git-summary", {
          description: "Show quick summary of git status",
          handler: async () => {
            console.log(execSync("git status -s", { encoding: "utf-8" }));
          }
        });
      }
    }
  '';
}
```

### 2. Define the Typed Module (`module.nix`)

```nix
{ lib, pkgs, config, ... }:

let
  cfg = config.programs.pi.extensions.git-summary;
  gitSummaryPkg = pkgs.callPackage ./default.nix {
    mkPiExtension = pkgs.callPackage ../../lib/mk-extension.nix { };
  };
in {
  options.programs.pi.extensions.git-summary = {
    enable = lib.mkEnableOption "Git summary Pi extension";
    package = lib.mkOption {
      type = lib.types.package;
      default = gitSummaryPkg;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.pi.runtimePackages = [ pkgs.git pkgs.jq ];
  };
}
```

---

## Flake Outputs & Public APIs
 
 - `lib.evalPi { pkgs, modules }` - Pure module evaluator
 - `lib.makePi { pkgs, modules }` - Generates configured Pi package
 - `lib.mkPiProvider { name, baseUrl, ... }` - Provider constructor
 - `lib.mkPiExtension { pname, src, runtimePackages, ... }` - Extension packager
 - `lib.mkPiSkill { name, content, description }` - Skill helper
 - `lib.mkPiPrompt { name, content, argumentHint }` - Prompt helper
 - `lib.mkPiTheme { name, colors }` - Theme helper
 - `piModules.default` - Core module aggregator
 - `piModules.skills.commit-style` - Conventional Commits skill module
 - `piModules.providers.antigravity` - Antigravity provider module
 - `packages.<system>.commit-style` - Conventional Commits skill package
 - `packages.<system>.antigravity` - Antigravity provider package
 - `homeManagerModules.default` - Home Manager integration module
 - `templates.standalone`, `templates.home-manager`, `templates.devshell` - Ready-to-use templates

---


## Testing & Verification

Run the comprehensive test suite with:

```bash
# Run all flake checks (eval tests, build tests, HM tests, offline E2E)
nix flake check

# Format Nix expressions
nix fmt
```

All test runs operate completely offline with `PI_OFFLINE=1` and never trigger paid API calls.
