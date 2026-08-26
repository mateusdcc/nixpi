# Research Tools & MCP Bridges Extension (`research-tools`)

Comprehensive legal-tech research extension bridging MCP servers, semantic search engines, web scraping APIs, RSS feeds, and local DuckDB evidence ledgers to the Pi coding agent.

## Features

- **BigIdeasDB**: Pre-clustered legal pain points, complaints, and SaaS revenue signals.
- **Exa Search**: Semantic neural search across legal-tech products and authoritative papers.
- **Firecrawl**: Markdown scraping and crawling for product pricing and case studies.
- **Apify Actors**: Allowlist-enforced scrapers (Reddit, G2, Capterra, Reclame Aqui, Trustpilot).
- **TrendRadar & RSS**: Multi-jurisdiction RSS aggregation and legal taxonomy keywords.
- **YouTube Transcripts**: Extract spoken transcripts from lawyer interviews and tutorials.
- **DuckDB Evidence Ledger**: Execute SQL against local validated opportunity ledgers.
- **Isolated Chrome**: Headless browser extraction for JavaScript-heavy pages.
- **Conditional Bridges**: Optional World Monitor macroeconomic queries, XiaoHongShu (XHS) Chinese market research, and GPT Researcher deep synthesis.

## Registered Tools

| Tool | Parameters | Description |
|---|---|---|
| `bigideasdb_query` | `endpoint`, `params` | Query pre-clustered pain points and SaaS signals. |
| `exa_search` | `query`, `category`, `numResults` | Semantic search for companies and reports. |
| `firecrawl_scrape` | `url`, `onlyMainContent` | Clean markdown extraction from web pages. |
| `apify_run_actor` | `actorId`, `input` | Run approved review or community scrapers from allowlist. |
| `trendradar_fetch_rss` | `feedUrl` | Fetch and parse RSS feed articles. |
| `trendradar_list_keywords` | - | List legal workflow and court keyword taxonomies. |
| `youtube_transcript_get` | `videoUrlOrId`, `languages` | Extract spoken transcript from video. |
| `duckdb_query` | `sql`, `dbPath` | Run SQL query against the DuckDB evidence ledger. |
| `duckdb_get_validated_opportunities`| `dbPath` | Retrieve opportunities satisfying evidence criteria. |
| `chrome_research_view` | `url` | Read-only extraction using isolated profile. |
| `world_monitor_query` | `topic`, `country` | Query macroeconomic context (conditional). |
| `xhs_research_query` | `keyword`, `page` | Search XiaoHongShu/RedNote (conditional). |
| `gpt_researcher_synthesize` | `query`, `reportType` | Deep report synthesis fallback (conditional). |

## Registered Commands

| Command | Description |
|---|---|
| `/research:status` | Check credentials, Chrome profile, Apify allowlist, and RSS sources status. |

## Nix Configuration

Enable the extension in your `programs.pi` configuration:

```nix
programs.pi.extensions.research-tools = {
  enable = true;
  enableWorldMonitor = false;
  enableXhs = false;
  enableGptResearcher = false;
};
```

### Module Parameters

| Option | Type | Default | Description |
|---|---|---|---|
| `enable` | `boolean` | `false` | Enable the research-tools extension in Pi. |
| `enableWorldMonitor` | `boolean` | `false` | Enable World Monitor macro context tool. |
| `enableXhs` | `boolean` | `false` | Enable XHS / RedNote Chinese market research tool. |
| `enableGptResearcher` | `boolean` | `false` | Enable GPT Researcher synthesis fallback tool. |
| `package` | `package` | `pkgs.piExtensions.research-tools` | Override package derivation providing the extension. |

### Environment Variables & Credentials

Set required API keys in your runtime environment:

| Variable | Description |
|---|---|
| `BIGIDEASDB_API_KEY` | API key for BigIdeasDB pain point database. |
| `EXA_API_KEY` | API key for Exa semantic search. |
| `FIRECRAWL_API_KEY` | API key for Firecrawl extraction service. |
| `APIFY_TOKEN` | API token for Apify scraper execution. |
| `WORLD_MONITOR_API_URL` | Endpoint URL for World Monitor (if enabled). |
| `XHS_API_URL` | Endpoint URL for XHS scraper (if enabled). |
| `GPTR_MCP_URL` | Endpoint URL for GPT Researcher server (if enabled). |
