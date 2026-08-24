import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { getObsidianConfigDir } from "./vault.js";
import { updateSettings } from "./settings.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export function getBundledPluginFiles() {
  const pluginDir = path.resolve(__dirname, "../obsidian-plugin");
  const manifestPath = path.join(pluginDir, "manifest.json");
  const mainJsPath = path.join(pluginDir, "main.js");
  const manifest = fs.readFileSync(manifestPath, "utf-8");
  const mainJs = fs.readFileSync(mainJsPath, "utf-8");
  return { manifest, mainJs };
}

export async function ensureCompanionPlugin(vaultDir) {
  if (!vaultDir) return { success: false, error: "No vault directory provided" };
  const targetDir = path.join(getObsidianConfigDir(vaultDir), "plugins", "pi-bridge");
  const { manifest, mainJs } = getBundledPluginFiles();

  await fs.promises.mkdir(targetDir, { recursive: true });
  await fs.promises.writeFile(path.join(targetDir, "manifest.json"), manifest, "utf-8");
  await fs.promises.writeFile(path.join(targetDir, "main.js"), mainJs, "utf-8");

  await updateSettings(vaultDir, "community-plugins", ["pi-bridge"]);
  return { success: true, targetDir, pluginId: "pi-bridge" };
}
