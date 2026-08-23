import fs from "node:fs";
import path from "node:path";

export function findVaultPath(explicitPath) {
  if (explicitPath && fs.existsSync(explicitPath)) {
    return path.resolve(explicitPath);
  }
  const envVault = process.env.OBSIDIAN_VAULT_PATH || process.env.OBSIDIAN_VAULT;
  if (envVault && fs.existsSync(envVault)) {
    return path.resolve(envVault);
  }
  return searchParentForVault(process.cwd());
}

export function searchParentForVault(startDir) {
  let curr = path.resolve(startDir);
  while (curr !== path.dirname(curr)) {
    if (fs.existsSync(path.join(curr, ".obsidian"))) {
      return curr;
    }
    curr = path.dirname(curr);
  }
  return path.resolve(startDir);
}

export function resolveNotePath(vaultDir, notePath) {
  const normalized = notePath.endsWith(".md") ? notePath : `${notePath}.md`;
  return path.isAbsolute(normalized)
    ? normalized
    : path.join(vaultDir, normalized);
}

export function getObsidianConfigDir(vaultDir) {
  return path.join(vaultDir, ".obsidian");
}

export async function listVaultMarkdownFiles(dir, baseDir = dir) {
  const entries = await fs.promises.readdir(dir, { withFileTypes: true });
  const files = await Promise.all(
    entries.map(async (entry) => {
      const fullPath = path.join(dir, entry.name);
      if (entry.name.startsWith(".")) return [];
      if (entry.isDirectory()) {
        return listVaultMarkdownFiles(fullPath, baseDir);
      }
      if (entry.isFile() && entry.name.endsWith(".md")) {
        return [path.relative(baseDir, fullPath)];
      }
      return [];
    })
  );
  return files.flat();
}
