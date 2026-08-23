import fs from "node:fs";
import path from "node:path";
import { resolveNotePath, listVaultMarkdownFiles } from "./vault.js";

const WIKILINK_REGEX = /(!?)\[\[([^\[\]]+)\]\]/g;
const MD_LINK_REGEX = /(!?)\[([^\]]*)\]\(([^)]+)\)/g;
const TAG_REGEX = /(?:^|\s)(#[a-zA-Z0-9_\-\/]+)(?=\s|$|[.,;:!])/g;

export function parseWikilink(raw) {
  const isEmbed = raw.startsWith("!");
  const content = isEmbed ? raw.slice(3, -2) : raw.slice(2, -2);
  const [targetPart, alias] = content.split("|");
  const [target, subpath] = targetPart.split("#");
  return {
    raw,
    type: isEmbed ? "embed" : "wikilink",
    target: target.trim(),
    subpath: subpath?.trim() || null,
    alias: alias?.trim() || null,
  };
}

export function parseMarkdownLink(match, isEmbed, text, target) {
  const isExternal = /^https?:\/\//i.test(target) || /^mailto:/i.test(target);
  return {
    raw: match,
    type: isEmbed === "!" ? "embed" : isExternal ? "external" : "internal",
    text: text.trim(),
    target: target.trim(),
  };
}

export function extractLinksFromContent(content, sourcePath = "") {
  const wikilinks = Array.from(content.matchAll(WIKILINK_REGEX), (m) => parseWikilink(m[0]));
  const mdLinks = Array.from(content.matchAll(MD_LINK_REGEX), (m) =>
    parseMarkdownLink(m[0], m[1], m[2], m[3])
  );
  const tags = Array.from(content.matchAll(TAG_REGEX), (m) => m[1]);
  return { sourcePath, wikilinks, mdLinks, tags: Array.from(new Set(tags)) };
}

export function normalizeTarget(target) {
  const cleaned = target.replace(/\\/g, "/").replace(/\.md$/i, "");
  return path.basename(cleaned).toLowerCase();
}

export function matchesNote(target, noteRelPath) {
  const noteClean = normalizeTarget(noteRelPath);
  const targetClean = normalizeTarget(target);
  return noteClean === targetClean;
}

export async function getNoteLinks(vaultDir, notePath) {
  const absPath = resolveNotePath(vaultDir, notePath);
  const relPath = path.relative(vaultDir, absPath);
  const content = await fs.promises.readFile(absPath, "utf-8");
  const links = extractLinksFromContent(content, relPath);
  const backlinks = await findBacklinksForNote(vaultDir, relPath);
  return {
    note: relPath,
    outgoing: {
      wikilinks: links.wikilinks,
      markdownLinks: links.mdLinks,
      tags: links.tags,
    },
    backlinks,
  };
}

export async function findBacklinksForNote(vaultDir, targetRelPath) {
  const allFiles = await listVaultMarkdownFiles(vaultDir);
  const backlinks = [];
  for (const file of allFiles) {
    if (file === targetRelPath) continue;
    const content = await fs.promises.readFile(path.join(vaultDir, file), "utf-8");
    const extracted = extractLinksFromContent(content, file);
    const hasRef = extracted.wikilinks.some((w) => matchesNote(w.target, targetRelPath)) ||
      extracted.mdLinks.some((m) => m.type === "internal" && matchesNote(m.target, targetRelPath));
    if (hasRef) backlinks.push({ file });
  }
  return backlinks;
}

export async function buildVaultLinkGraph(vaultDir) {
  const allFiles = await listVaultMarkdownFiles(vaultDir);
  const knownNotes = new Set(allFiles.map(normalizeTarget));
  const graph = { nodes: [], edges: [], orphanNotes: [], brokenLinks: [], externalUrls: [], stats: {} };
  const incomingCounts = new Map(allFiles.map((f) => [f, 0]));

  for (const file of allFiles) {
    const content = await fs.promises.readFile(path.join(vaultDir, file), "utf-8");
    const extracted = extractLinksFromContent(content, file);
    processFileLinks(file, extracted, knownNotes, incomingCounts, graph);
  }
  computeGraphSummaries(allFiles, incomingCounts, graph);
  return graph;
}

function processFileLinks(file, extracted, knownNotes, incomingCounts, graph) {
  const outTargets = [];
  for (const w of extracted.wikilinks) {
    if (w.target) {
      outTargets.push(w.target);
      graph.edges.push({ source: file, target: w.target, type: w.type });
      if (!knownNotes.has(normalizeTarget(w.target))) {
        graph.brokenLinks.push({ source: file, target: w.target });
      }
    }
  }
  for (const m of extracted.mdLinks) {
    if (m.type === "external") graph.externalUrls.push(m.target);
    if (m.type === "internal" && m.target) {
      outTargets.push(m.target);
      graph.edges.push({ source: file, target: m.target, type: "markdown" });
    }
  }
  graph.nodes.push({ file, outgoingCount: outTargets.length, tags: extracted.tags });
}

function computeGraphSummaries(allFiles, incomingCounts, graph) {
  for (const edge of graph.edges) {
    const matched = allFiles.find((f) => matchesNote(edge.target, f));
    if (matched) incomingCounts.set(matched, (incomingCounts.get(matched) || 0) + 1);
  }
  graph.orphanNotes = graph.nodes
    .filter((n) => n.outgoingCount === 0 && (incomingCounts.get(n.file) || 0) === 0)
    .map((n) => n.file);
  graph.stats = {
    totalNotes: allFiles.length,
    totalInternalLinks: graph.edges.length,
    totalBrokenLinks: graph.brokenLinks.length,
    totalOrphanNotes: graph.orphanNotes.length,
    totalExternalUrls: graph.externalUrls.length,
  };
}
