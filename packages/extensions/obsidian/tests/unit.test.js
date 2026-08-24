import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import os from "node:os";

import {
  parseWikilink,
  parseMarkdownLink,
  extractLinksFromContent,
  normalizeTarget,
  matchesNote,
  getNoteLinks,
  buildVaultLinkGraph,
} from "../extensions/links.js";
import { readSettings, updateSettings, resolveConfigFile } from "../extensions/settings.js";
import { parseGitHubRepo } from "../extensions/installer.js";
import { getClientConfig, buildHeaders, getCoreFallbackCommands } from "../extensions/client.js";

async function runTests() {
  console.log("Running Obsidian extension unit tests...");

  // 1. Wikilink parsing
  const w1 = parseWikilink("[[Target Note]]");
  assert.equal(w1.target, "Target Note");
  assert.equal(w1.type, "wikilink");
  assert.equal(w1.alias, null);

  const w2 = parseWikilink("[[Target Note|Alias Display]]");
  assert.equal(w2.target, "Target Note");
  assert.equal(w2.alias, "Alias Display");

  const w3 = parseWikilink("[[Target Note#Section Title|Alias]]");
  assert.equal(w3.target, "Target Note");
  assert.equal(w3.subpath, "Section Title");
  assert.equal(w3.alias, "Alias");

  const wEmbed = parseWikilink("![[screenshot.png]]");
  assert.equal(wEmbed.type, "embed");
  assert.equal(wEmbed.target, "screenshot.png");

  // 2. Markdown link parsing
  const m1 = parseMarkdownLink("[Google](https://google.com)", "", "Google", "https://google.com");
  assert.equal(m1.type, "external");

  const m2 = parseMarkdownLink("[Local](subfolder/other.md)", "", "Local", "subfolder/other.md");
  assert.equal(m2.type, "internal");

  // 3. Extract links from sample markdown content
  const sampleDoc = `
# Sample Note
Here is a link to [[Second Note|Second]] and an embed ![[diagram.png]].
External link: [OpenAI](https://openai.com).
Tags: #project/nix #obsidian-dev.
`;
  const extracted = extractLinksFromContent(sampleDoc, "Sample.md");
  assert.equal(extracted.wikilinks.length, 2);
  assert.equal(extracted.mdLinks.length, 1);
  assert.equal(extracted.tags.length, 2);
  assert.ok(extracted.tags.includes("#project/nix"));
  assert.ok(extracted.tags.includes("#obsidian-dev"));

  // 4. Temporary Vault for File System & Graph tests
  const tmpVault = await fs.promises.mkdtemp(path.join(os.tmpdir(), "nixpi-obsidian-vault-"));
  try {
    await fs.promises.mkdir(path.join(tmpVault, ".obsidian"), { recursive: true });
    await fs.promises.writeFile(path.join(tmpVault, "NoteA.md"), "Link to [[NoteB]] and [[MissingNote]] #topic", "utf-8");
    await fs.promises.writeFile(path.join(tmpVault, "NoteB.md"), "Backlink to [[NoteA]] and external [Docs](https://nixos.org)", "utf-8");
    await fs.promises.writeFile(path.join(tmpVault, "OrphanNote.md"), "No links anywhere", "utf-8");

    // Note links and backlinks
    const noteALinks = await getNoteLinks(tmpVault, "NoteA.md");
    assert.equal(noteALinks.outgoing.wikilinks.length, 2);
    assert.equal(noteALinks.backlinks.length, 1);
    assert.equal(noteALinks.backlinks[0].file, "NoteB.md");

    // Vault link graph
    const graph = await buildVaultLinkGraph(tmpVault);
    assert.equal(graph.stats.totalNotes, 3);
    assert.equal(graph.stats.totalOrphanNotes, 1);
    assert.ok(graph.orphanNotes.includes("OrphanNote.md"));
    assert.equal(graph.stats.totalBrokenLinks, 1);
    assert.equal(graph.brokenLinks[0].target, "MissingNote");
    assert.equal(graph.stats.totalExternalUrls, 1);

    // 5. Settings tests
    const appSettings = await readSettings(tmpVault, "app");
    assert.ok(appSettings.success);

    const updateRes = await updateSettings(tmpVault, "app", { livePreview: true, tabSize: 4 });
    assert.ok(updateRes.success);
    assert.equal(updateRes.updatedData.tabSize, 4);

    const pluginSettings = await updateSettings(tmpVault, "community-plugins", ["dataview"]);
    assert.ok(pluginSettings.success);
    assert.ok(pluginSettings.updatedData.includes("dataview"));

    const pluginData = await updateSettings(tmpVault, "plugin:dataview", { enableSql: true });
    assert.ok(pluginData.success);
    assert.equal(pluginData.updatedData.enableSql, true);

    // 6. Test Companion Plugin deployment
    const { ensureCompanionPlugin } = await import("../extensions/bridge.js");
    const bridgeDeploy = await ensureCompanionPlugin(tmpVault);
    assert.ok(bridgeDeploy.success);
    assert.ok(fs.existsSync(path.join(tmpVault, ".obsidian", "plugins", "pi-bridge", "manifest.json")));
    assert.ok(fs.existsSync(path.join(tmpVault, ".obsidian", "plugins", "pi-bridge", "main.js")));
    const pluginsJson = await readSettings(tmpVault, "community-plugins");
    assert.ok(pluginsJson.data.includes("pi-bridge"));

    // 7. Test getObsidianLayout offline fallback
    const { getObsidianLayout } = await import("../extensions/client.js");
    await fs.promises.writeFile(path.join(tmpVault, ".obsidian", "workspace.json"), JSON.stringify({ main: { type: "split" } }), "utf-8");
    const layoutRes = await getObsidianLayout({ url: "http://127.0.0.1:9999" }, tmpVault);
    assert.ok(layoutRes.success);
    assert.equal(layoutRes.layout.main.type, "split");
  } finally {
    await fs.promises.rm(tmpVault, { recursive: true, force: true });
  }

  // 7. Test URI resolution with path directory
  const { openViaObsidianUri } = await import("../extensions/client.js");
  const uriRes = await openViaObsidianUri("Concepts/LegalGraphRAG.md", "/Users/mateusdcc/Projects/my-real-tho");
  assert.ok(uriRes.uri.includes("vault=my-real-tho"));
  assert.ok(uriRes.uri.includes("file=Concepts%2FLegalGraphRAG.md"));

  // 6. GitHub URL parser tests
  const gh1 = parseGitHubRepo("https://github.com/blacksmithgu/obsidian-dataview");
  assert.equal(gh1.owner, "blacksmithgu");
  assert.equal(gh1.repo, "obsidian-dataview");
  assert.equal(gh1.tag, "latest");

  const gh2 = parseGitHubRepo("https://github.com/user/plugin/releases/tag/v1.2.3");
  assert.equal(gh2.tag, "v1.2.3");

  const gh3 = parseGitHubRepo("owner/my-plugin");
  assert.equal(gh3.owner, "owner");
  assert.equal(gh3.repo, "my-plugin");

  // 7. Client config & headers
  const conf = getClientConfig("http://localhost:27123", "secret-token");
  assert.equal(conf.url, "http://localhost:27123");
  const headers = buildHeaders(conf.apiKey);
  assert.equal(headers.Authorization, "Bearer secret-token");

  // 8. Core fallback commands
  const fallbacks = getCoreFallbackCommands();
  assert.ok(fallbacks.some((c) => c.id === "workspace:split-vertical"));
  assert.ok(fallbacks.some((c) => c.id === "app:open-settings"));

  console.log("All unit tests passed successfully!");
}

runTests().catch((err) => {
  console.error("Test failed:", err);
  process.exit(1);
});
