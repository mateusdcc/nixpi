import fs from "node:fs";
import path from "node:path";
import https from "node:https";
import { getObsidianConfigDir } from "./vault.js";
import { updateSettings } from "./settings.js";

export function parseGitHubRepo(rawInput) {
  const clean = rawInput.trim().replace(/^git@github\.com:/, "https://github.com/");
  const match = clean.match(/(?:https?:\/\/)?(?:www\.)?github\.com\/([^\/]+)\/([^\/\#\?]+)(?:\/releases\/(?:tag\/)?([^\/\#\?]+))?/i);
  if (match) {
    return {
      owner: match[1],
      repo: match[2].replace(/\.git$/, ""),
      tag: match[3] || "latest",
    };
  }
  const shorthand = rawInput.trim().match(/^([a-zA-Z0-9_\-\.]+)\/([a-zA-Z0-9_\-\.]+)$/);
  if (shorthand) {
    return { owner: shorthand[1], repo: shorthand[2], tag: "latest" };
  }
  throw new Error(`Invalid GitHub repository or release URL: ${rawInput}`);
}

export function fetchUrl(targetUrl) {
  return new Promise((resolve, reject) => {
    https.get(targetUrl, { headers: { "User-Agent": "nixpi-obsidian-installer" } }, (res) => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        return resolve(fetchUrl(res.headers.location));
      }
      if (res.statusCode !== 200) {
        return reject(new Error(`HTTP ${res.statusCode} fetching ${targetUrl}`));
      }
      let data = "";
      res.on("data", (chunk) => { data += chunk; });
      res.on("end", () => resolve(data));
    }).on("error", reject);
  });
}

export async function tryFetchFile(owner, repo, tag, filename) {
  const releaseUrl = tag === "latest"
    ? `https://github.com/${owner}/${repo}/releases/latest/download/${filename}`
    : `https://github.com/${owner}/${repo}/releases/download/${tag}/${filename}`;
  try {
    return await fetchUrl(releaseUrl);
  } catch {
    const rawUrl = `https://raw.githubusercontent.com/${owner}/${repo}/HEAD/${filename}`;
    return await fetchUrl(rawUrl).catch(() => null);
  }
}

export async function installPluginFromGitHub(vaultDir, githubUrl) {
  const { owner, repo, tag } = parseGitHubRepo(githubUrl);
  const manifestRaw = await tryFetchFile(owner, repo, tag, "manifest.json");
  if (!manifestRaw) {
    throw new Error(`Could not find manifest.json for ${owner}/${repo} (${tag})`);
  }
  const manifest = JSON.parse(manifestRaw);
  const pluginId = manifest.id || repo;
  const mainJs = await tryFetchFile(owner, repo, tag, "main.js");
  if (!mainJs) {
    throw new Error(`Could not find main.js for ${owner}/${repo} (${tag})`);
  }
  const stylesCss = await tryFetchFile(owner, repo, tag, "styles.css");
  return saveAndEnablePlugin(vaultDir, pluginId, manifestRaw, mainJs, stylesCss, manifest);
}

export async function saveAndEnablePlugin(vaultDir, pluginId, manifestRaw, mainJs, stylesCss, manifest) {
  const pluginDir = path.join(getObsidianConfigDir(vaultDir), "plugins", pluginId);
  await fs.promises.mkdir(pluginDir, { recursive: true });
  await fs.promises.writeFile(path.join(pluginDir, "manifest.json"), manifestRaw, "utf-8");
  await fs.promises.writeFile(path.join(pluginDir, "main.js"), mainJs, "utf-8");
  const installedFiles = ["manifest.json", "main.js"];
  if (stylesCss) {
    await fs.promises.writeFile(path.join(pluginDir, "styles.css"), stylesCss, "utf-8");
    installedFiles.push("styles.css");
  }
  await updateSettings(vaultDir, "community-plugins", [pluginId]);
  return {
    success: true,
    pluginId,
    name: manifest.name || pluginId,
    version: manifest.version || "unknown",
    installedFiles,
    pluginDir,
  };
}
