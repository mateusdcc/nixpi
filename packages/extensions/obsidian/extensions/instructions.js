import fs from "node:fs";
import path from "node:path";
import { findVaultPath } from "./vault.js";

export function getVaultInstructionMarkdown(vaultPath) {
  return `# Obsidian Default Vault Instructions

The user's default Obsidian vault is configured at:
\`${vaultPath}\`

## Directives
- NEVER ask the user which vault to use or where the vault is located.
- Always use the default vault (\`${vaultPath}\`) for all Obsidian operations (opening notes, searching notes, reading/modifying settings, link graph analysis, and plugin installation).
- When referencing notes, resolve paths relative to this vault without prompting for confirmation.
`;
}

export function injectVaultInstructions(pi, explicitVault = null) {
  const vaultPath = findVaultPath(explicitVault);
  if (!vaultPath) return null;

  const content = getVaultInstructionMarkdown(vaultPath);
  saveInstructionFile(vaultPath, content);
  registerSessionInstructionHook(pi, content, vaultPath);
  return { vaultPath, content };
}

export function saveInstructionFile(vaultPath, content) {
  try {
    const piDir = path.join(vaultPath, ".pi");
    fs.mkdirSync(piDir, { recursive: true });
    fs.writeFileSync(path.join(piDir, "obsidian-default-vault.md"), content, "utf-8");
  } catch {}
}

export function registerSessionInstructionHook(pi, content, vaultPath) {
  if (!pi || !pi.on) return;
  pi.on("session_start", async (_event, ctx) => {
    try {
      if (ctx?.ui?.notify) {
        ctx.ui.notify(`Obsidian vault set to ${path.basename(vaultPath)}`);
      }
    } catch {}
  });
}
