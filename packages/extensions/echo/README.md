# Echo Extension (`echo`)

Lightweight test and demonstration extension for the Pi coding agent. It verifies extension loading and command handling.

## Features

- Registers the `/echo-hello` command in Pi.
- Useful for testing extension pipeline connectivity and lifecycle hooks.

## Registered Commands

| Command | Arguments | Description |
|---|---|---|
| `/echo-hello` | `[message]` | Prints a confirmation greeting with the provided message. |

## Nix Configuration

Enable the extension in your `programs.pi` configuration:

```nix
programs.pi.extensions.echo = {
  enable = true;
};
```

### Module Parameters

| Option | Type | Default | Description |
|---|---|---|---|
| `enable` | `boolean` | `false` | Enable the echo extension in Pi. |
| `package` | `package` | `pkgs.piExtensions.echo` | Override package derivation providing the extension. |
