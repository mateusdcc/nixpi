# Pi GPT Search Extension (`pi-gpt-search`)

Model-independent, standalone web search extension for the Pi coding agent powered by OpenAI Codex search engine.

- **Upstream Repository**: [mateusdcc/pi-gpt-search](https://github.com/mateusdcc/pi-gpt-search)

## Features

- Provides model-independent web search capabilities to any LLM running in Pi.
- Debug mode for detailed query trace logs.

## Nix Configuration

Enable the extension in your `programs.pi` configuration:

```nix
programs.pi.extensions.pi-gpt-search = {
  enable = true;
  debug = false;
};
```

### Module Parameters

| Option | Type | Default | Description |
|---|---|---|---|
| `enable` | `boolean` | `false` | Enable the pi-gpt-search extension in Pi. |
| `debug` | `boolean` | `false` | Enable debug logging for search queries (`PI_WEB_SEARCH_DEBUG=1`). |
| `package` | `package` | `pkgs.piExtensions.pi-gpt-search` | Override package derivation providing the extension. |

### Environment Variables & Credentials

Provide credentials at runtime via environment variables:

| Variable | Required | Description |
|---|---|---|
| `CODEX_ACCESS_TOKEN` | Optional | Codex API authentication access token. |
| `CODEX_ACCOUNT_ID` | Optional | Codex account identifier. |
| `PI_WEB_SEARCH_DEBUG` | Optional | Set to `1` when `debug = true` is configured. |
