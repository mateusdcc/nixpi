# Plan Mode Extension (`plan-mode`)

Structured multi-step task planning extension with configurable execution modes and step limits.

## Features

- Registers the `/plan` command in Pi.
- Injects typed planning preferences into `settings.json` under `settings.planMode`.

## Registered Commands

| Command | Arguments | Description |
|---|---|---|
| `/plan` | `[task description]` | Triggers structured planning execution for a given task. |

## Nix Configuration

Enable and configure planning mode in your `programs.pi` configuration:

```nix
programs.pi.extensions.plan-mode = {
  enable = true;
  mode = "thorough"; # "fast" | "balanced" | "thorough"
  maxSteps = 20;
  autoApprove = false;
};
```

### Module Parameters

| Option | Type | Default | Description |
|---|---|---|---|
| `enable` | `boolean` | `false` | Enable the plan-mode extension in Pi. |
| `mode` | `enum ["fast", "balanced", "thorough"]` | `"balanced"` | Planning depth and rigor mode. |
| `maxSteps` | `integer` | `10` | Maximum number of plan steps allowed during execution. |
| `autoApprove` | `boolean` | `false` | Automatically approve execution steps without interactive confirmation. |
| `package` | `package` | `pkgs.piExtensions.plan-mode` | Override package derivation providing the extension. |
