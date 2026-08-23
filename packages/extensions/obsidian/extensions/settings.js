import fs from "node:fs";
import path from "node:path";
import { getObsidianConfigDir } from "./vault.js";

export function resolveConfigFile(vaultDir, configType) {
  const configDir = getObsidianConfigDir(vaultDir);
  if (configType.startsWith("plugin:")) {
    const pluginId = configType.replace("plugin:", "");
    return path.join(configDir, "plugins", pluginId, "data.json");
  }
  const cleanType = configType.endsWith(".json") ? configType : `${configType}.json`;
  return path.join(configDir, cleanType);
}

export async function readSettings(vaultDir, configType = "app") {
  const filePath = resolveConfigFile(vaultDir, configType);
  try {
    const content = await fs.promises.readFile(filePath, "utf-8");
    return { success: true, file: filePath, data: JSON.parse(content) };
  } catch (err) {
    if (err.code === "ENOENT") {
      return { success: true, file: filePath, data: {}, isNew: true };
    }
    return { success: false, file: filePath, error: err.message };
  }
}

export async function updateSettings(vaultDir, configType, updates) {
  const filePath = resolveConfigFile(vaultDir, configType);
  const current = await readSettings(vaultDir, configType);
  if (!current.success) return current;

  let merged;
  if (Array.isArray(updates)) {
    const currentList = Array.isArray(current.data) ? current.data : [];
    merged = Array.from(new Set([...currentList, ...updates]));
  } else {
    merged = { ...(current.data || {}), ...updates };
  }

  await fs.promises.mkdir(path.dirname(filePath), { recursive: true });
  await fs.promises.writeFile(filePath, JSON.stringify(merged, null, 2), "utf-8");
  return { success: true, file: filePath, updatedData: merged };
}

export async function listAllSettings(vaultDir) {
  const configDir = getObsidianConfigDir(vaultDir);
  try {
    const entries = await fs.promises.readdir(configDir, { withFileTypes: true });
    const configs = entries
      .filter((e) => e.isFile() && e.name.endsWith(".json"))
      .map((e) => e.name.replace(".json", ""));
    return { success: true, availableConfigs: configs, configDir };
  } catch (err) {
    return { success: false, error: err.message, configDir };
  }
}
