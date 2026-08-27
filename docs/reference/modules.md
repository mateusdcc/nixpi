# Bundled modules

Import the complete module with `nixpi.piModules.default`, or import a focused module from the output names below. The [generated option reference](options.md) is authoritative for every option exposed by these modules.

## Core and profiles

| Output | Purpose |
| --- | --- |
| `piModules.base` | Core options without bundled features. |
| `piModules.default` | Core plus the bundled feature modules. |
| `piModules.profiles.minimal` | Minimal Pi configuration. |
| `piModules.profiles.research` | Research-oriented configuration. |
| `piModules.profiles.legalResearch` | Legal research configuration. |

`piModules.profiles.learning` remains a deprecated compatibility alias for deep-comprehension-engine.

## Extensions

| Output | Enable with | Use |
| --- | --- | --- |
| `piModules.extensions.echo` | `extensions.echo.enable = true;` | Simple command extension and package example. |
| `piModules.extensions.ripgrep-search` | `extensions.ripgrep-search.enable = true;` | Repository search using ripgrep. |
| `piModules.extensions.plan-mode` | `extensions.plan-mode.enable = true;` | Planning workflow controls. |
| `piModules.extensions.pi-gpt-search` | `extensions.pi-gpt-search.enable = true;` | GPT-powered search integration. |
| `piModules.extensions.researchTools` | `extensions.research-tools.enable = true;` | Research tools and MCP bridges. |

`piModules.extensions.obsidian` is a deprecated compatibility alias. Configure the replacement from deep-comprehension-engine for new work.

## Skills

Enable a bundled skill through `programs.pi.skills`:

```nix
programs.pi.skills = {
  commit-style.enable = true;
  legal-pain-discovery.enable = true;
  voice-of-customer-mining.enable = true;
  evidence-deduplication.enable = true;
  legal-market-segmentation.enable = true;
  competitor-gap-analysis.enable = true;
  brazil-localization-test.enable = true;
  opportunity-scoring.enable = true;
  product-opportunity-report.enable = true;
};
```

The corresponding public module outputs are `commit-style`, `legalPainDiscovery`, `voiceOfCustomerMining`, `evidenceDeduplication`, `legalMarketSegmentation`, `competitorGapAnalysis`, `brazilLocalizationTest`, `opportunityScoring`, and `productOpportunityReport` under `piModules.skills`.

The former learning skills under `piModules.skills` are compatibility aliases that warn and point to deep-comprehension-engine.

## Providers

`piModules.providers.antigravity` adds the Antigravity provider module. It can be enabled through the normal `programs.pi.providers.antigravity` option tree. Use the provider's generated options for models, endpoint, package, and credential requirements.

## Host modules

| Output | Alias | Use |
| --- | --- | --- |
| `homeModules.default` | `homeModules.pi`, `homeManagerModules` | Home Manager. |
| `nixosModules.default` | `nixosModules.pi` | NixOS. |
| `nixDarwinModules.default` | `nixDarwinModules.pi` | nix-darwin. |
