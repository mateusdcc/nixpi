# Ripgrep Search Extension (`ripgrep-search`)

Fast, regex-powered file content search extension for the Pi coding agent using `ripgrep` (`rg`).

## Features

- Registers the `rg_search` tool for Pi to inspect codebases quickly.
- Automatically brings `pkgs.ripgrep` into Pi's runtime `PATH`.

## Registered Tools

| Tool | Parameters | Description |
|---|---|---|
| `rg_search` | `pattern` (string, required) | Searches directory file contents matching a regex pattern with line numbers. |

## Nix Configuration

Enable the extension in your `programs.pi` configuration:

```nix
programs.pi.extensions.ripgrep-search = {
  enable = true;
};
```

### Module Parameters

| Option | Type | Default | Description |
|---|---|---|---|
| `enable` | `boolean` | `false` | Enable the ripgrep-search extension in Pi. |
| `package` | `package` | `pkgs.piExtensions.ripgrep-search` | Override package derivation providing the extension. |
