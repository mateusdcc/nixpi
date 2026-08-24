/**
 * NixPi Legal Research Tools & MCP Bridges Extension
 */

import { queryBigIdeasDb } from "../bigideasdb.js";
import { searchExa } from "../exa.js";
import { scrapeFirecrawl, crawlFirecrawl } from "../firecrawl.js";
import { runApifyActor, ALLOWED_ACTORS } from "../apify.js";
import { fetchRssFeed, LEGAL_KEYWORD_GROUPS, RSS_FEEDS } from "../trendradar.js";
import { getYouTubeTranscript } from "../youtube.js";
import { executeDuckDb, getValidatedOpportunities } from "../duckdb.js";
import { fetchPageIsolatedChrome, getChromeProfileDir } from "../chrome.js";
import { queryWorldMonitor } from "../worldmonitor.js";
import { queryXhs } from "../xhs.js";
import { runGptResearcherSynthesis } from "../gptr.js";

function respond(data) {
  const text = typeof data === "string" ? data : JSON.stringify(data, null, 2);
  return { content: [{ type: "text", text }] };
}

export default function (pi) {
  if (!pi || !pi.registerTool) return;

  // 1. BigIdeasDB
  pi.registerTool({
    name: "bigideasdb_query",
    label: "BigIdeasDB Query",
    description: "Search pre-clustered pain points, complaints, G2/Reddit insights, and SaaS revenue signals",
    parameters: {
      type: "object",
      properties: {
        endpoint: { type: "string", description: "API endpoint (e.g. pains, complaints, revenue-signals)" },
        params: { type: "object", description: "Query parameters" },
      },
      required: ["endpoint"],
    },
    async execute(id, params) {
      const res = await queryBigIdeasDb(params.endpoint, params.params || {});
      return respond(res);
    },
  });

  // 2. Exa Semantic Search
  pi.registerTool({
    name: "exa_search",
    label: "Exa Semantic Search",
    description: "Semantic search for legal-tech products, companies, and authoritative legal reports",
    parameters: {
      type: "object",
      properties: {
        query: { type: "string", description: "Semantic search query" },
        category: { type: "string", enum: ["company", "research paper", "news", "general"], default: "company" },
        numResults: { type: "number", default: 10 },
      },
      required: ["query"],
    },
    async execute(id, params) {
      const res = await searchExa(params.query, params);
      return respond(res);
    },
  });

  // 3. Firecrawl Scrape & Crawl
  pi.registerTool({
    name: "firecrawl_scrape",
    label: "Firecrawl Scrape Page",
    description: "Clean markdown extraction from known URLs for pricing, features, and case studies",
    parameters: {
      type: "object",
      properties: {
        url: { type: "string", description: "Page URL to scrape" },
        onlyMainContent: { type: "boolean", default: true },
      },
      required: ["url"],
    },
    async execute(id, params) {
      const res = await scrapeFirecrawl(params.url, params);
      return respond(res);
    },
  });

  // 4. Apify Actor Execution with Allowlist
  pi.registerTool({
    name: "apify_run_actor",
    label: "Apify Run Approved Actor",
    description: "Execute maintained review, community, and job scraper actors from allowlist",
    parameters: {
      type: "object",
      properties: {
        actorId: { type: "string", description: "Approved actor identifier (e.g. apify/reddit-scraper, memo23/g2-reviews-scraper)" },
        input: { type: "object", description: "Actor run input payload" },
      },
      required: ["actorId"],
    },
    async execute(id, params) {
      const res = await runApifyActor(params.actorId, params.input || {});
      return respond(res);
    },
  });

  // 5. TrendRadar & RSS
  pi.registerTool({
    name: "trendradar_fetch_rss",
    label: "TrendRadar RSS Ingestion",
    description: "Fetch RSS feed from legal-tech and law-practice publication sources",
    parameters: {
      type: "object",
      properties: { feedUrl: { type: "string", description: "RSS Feed URL" } },
      required: ["feedUrl"],
    },
    async execute(id, params) {
      const res = await fetchRssFeed(params.feedUrl);
      return respond(res);
    },
  });

  pi.registerTool({
    name: "trendradar_list_keywords",
    label: "TrendRadar Legal Keywords",
    description: "List legal workflow and Brazilian court system keyword taxonomies",
    parameters: { type: "object", properties: {} },
    async execute() {
      return respond({ keywords: LEGAL_KEYWORD_GROUPS, feeds: RSS_FEEDS });
    },
  });

  // 6. YouTube Transcript Extractor
  pi.registerTool({
    name: "youtube_transcript_get",
    label: "YouTube Transcript Extractor",
    description: "Extract spoken transcripts from lawyer interviews, panels, and software tutorials",
    parameters: {
      type: "object",
      properties: {
        videoUrlOrId: { type: "string", description: "YouTube URL or 11-character video ID" },
        languages: { type: "string", default: "en,pt,es", description: "Comma-separated language preferences" },
      },
      required: ["videoUrlOrId"],
    },
    async execute(id, params) {
      const res = getYouTubeTranscript(params.videoUrlOrId, params.languages);
      return respond(res);
    },
  });

  // 7. DuckDB Evidence Ledger
  pi.registerTool({
    name: "duckdb_query",
    label: "DuckDB Ledger Query",
    description: "Execute SQL queries against the local DuckDB evidence ledger",
    parameters: {
      type: "object",
      properties: {
        sql: { type: "string", description: "SQL query to execute" },
        dbPath: { type: "string", description: "Optional override path to DuckDB ledger file" },
      },
      required: ["sql"],
    },
    async execute(id, params) {
      const res = executeDuckDb(params.sql, params.dbPath);
      return respond(res);
    },
  });

  pi.registerTool({
    name: "duckdb_get_validated_opportunities",
    label: "DuckDB Validated Opportunities",
    description: "Fetch opportunities satisfying all 6 evidence validation standards",
    parameters: { type: "object", properties: {} },
    async execute(id, params) {
      const res = getValidatedOpportunities(params?.dbPath);
      return respond(res);
    },
  });

  // 8. Chrome Isolated Profile Reader
  pi.registerTool({
    name: "chrome_research_view",
    label: "Chrome Isolated Research View",
    description: "Read-only web extraction using an isolated profile when APIs are blocked",
    parameters: {
      type: "object",
      properties: { url: { type: "string", description: "Target URL to inspect" } },
      required: ["url"],
    },
    async execute(id, params) {
      const res = fetchPageIsolatedChrome(params.url);
      return respond(res);
    },
  });

  // 9. Conditional Tools (World Monitor, XHS, GPT Researcher)
  pi.registerTool({
    name: "world_monitor_query",
    label: "World Monitor Macro Context",
    description: "Query macroeconomic and regulatory changes (conditional, not for pain points)",
    parameters: {
      type: "object",
      properties: { topic: { type: "string" }, country: { type: "string", default: "BR" } },
      required: ["topic"],
    },
    async execute(id, params) {
      const res = await queryWorldMonitor(params.topic, params.country);
      return respond(res);
    },
  });

  pi.registerTool({
    name: "xhs_research_query",
    label: "XHS China Market Query",
    description: "Query XiaoHongShu/RedNote for China-specific legal workflow research (conditional)",
    parameters: {
      type: "object",
      properties: { keyword: { type: "string" }, page: { type: "number", default: 1 } },
      required: ["keyword"],
    },
    async execute(id, params) {
      const res = await queryXhs(params.keyword, params);
      return respond(res);
    },
  });

  pi.registerTool({
    name: "gpt_researcher_synthesize",
    label: "GPT Researcher Synthesis Fallback",
    description: "Optional fallback deep report synthesizer (conditional)",
    parameters: {
      type: "object",
      properties: { query: { type: "string" }, reportType: { type: "string", default: "research_report" } },
      required: ["query"],
    },
    async execute(id, params) {
      const res = await runGptResearcherSynthesis(params.query, params.reportType);
      return respond(res);
    },
  });

  // Commands
  if (pi.registerCommand) {
    pi.registerCommand("research:status", {
      description: "Check status of research tools, credentials, and evidence ledger",
      handler: async () => {
        const creds = {
          BIGIDEASDB_API_KEY: Boolean(process.env.BIGIDEASDB_API_KEY),
          EXA_API_KEY: Boolean(process.env.EXA_API_KEY),
          FIRECRAWL_API_KEY: Boolean(process.env.FIRECRAWL_API_KEY),
          APIFY_TOKEN: Boolean(process.env.APIFY_TOKEN || process.env.APIFY_API_TOKEN),
          OPENAI_API_KEY: Boolean(process.env.OPENAI_API_KEY),
        };
        console.log("=== NixPi Legal Research Tools Status ===");
        console.log("Credentials configured:", creds);
        console.log("Chrome profile path:", getChromeProfileDir());
        console.log("Apify Actor allowlist count:", ALLOWED_ACTORS.length);
        console.log("TrendRadar RSS feed count:", RSS_FEEDS.global.length + RSS_FEEDS.brazil.length);
      },
    });
  }
}
