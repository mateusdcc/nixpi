# Container tests

nixpi builds its CI images directly with Nix. No imperative Dockerfile installation is involved, so the Pi package and scenario configuration use the same locked inputs as every other output.

## Scenarios

| Scenario | Coverage |
| --- | --- |
| `minimal` | Pi startup with no optional extensions or skills |
| `features` | Echo, ripgrep search, plan mode, and commit-style skill |
| `provider` | Custom OpenAI-compatible provider and required runtime secret |

Each scenario has two checks:

1. A flake check executes Pi and validates generated JSON with `jq`.
2. Docker CI builds the image, loads it into Docker, verifies its scenario label, and runs the same test inside the container as an unprivileged user.

Docker CI runs every scenario on x86_64 Linux and ARM Linux.

## Run locally on Linux

```console
nix build .#docker-features
docker load < result
docker run --rm nixpi-ci-features:edge
```

Run only the configuration-level check with:

```console
nix build .#checks.$(nix eval --impure --raw --expr builtins.currentSystem).container-features-tests
```
