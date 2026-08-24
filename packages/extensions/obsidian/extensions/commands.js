import { findVaultPath } from "./vault.js";
import {
  openNoteInApp,
  splitObsidianScreen,
  listObsidianCommands,
  runObsidianCommand,
  openObsidianSettings,
} from "./client.js";
import { getNoteLinks, buildVaultLinkGraph } from "./links.js";
import { installPluginFromGitHub } from "./installer.js";
import { ensureCompanionPlugin } from "./bridge.js";

export function registerObsidianCommands(pi) {
  if (!pi || !pi.registerCommand) return;

  pi.registerCommand("obsidian-bridge", {
    description: "Install Pi Bridge plugin in vault: /obsidian-bridge",
    handler: async () => {
      const vaultDir = findVaultPath();
      const res = await ensureCompanionPlugin(vaultDir);
      console.log(JSON.stringify(res, null, 2));
    },
  });

  pi.registerCommand("obsidian-open", {
    description: "Open a note in Obsidian UI: /obsidian-open <file>",
    handler: async (args) => {
      const file = args?.trim();
      if (!file) return console.log("Usage: /obsidian-open <note-path>");
      const vaultDir = findVaultPath();
      const res = await openNoteInApp(file, vaultDir);
      console.log(JSON.stringify(res, null, 2));
    },
  });

  pi.registerCommand("obsidian-split", {
    description: "Split editor pane: /obsidian-split [vertical|horizontal]",
    handler: async (args) => {
      const dir = args?.trim() || "vertical";
      const res = await splitObsidianScreen(dir);
      console.log(JSON.stringify(res, null, 2));
    },
  });

  pi.registerCommand("obsidian-commands", {
    description: "List available Obsidian commands: /obsidian-commands",
    handler: async () => {
      const res = await listObsidianCommands();
      console.log(JSON.stringify(res, null, 2));
    },
  });

  pi.registerCommand("obsidian-run", {
    description: "Run an Obsidian command: /obsidian-run <command-id>",
    handler: async (args) => {
      const cmd = args?.trim();
      if (!cmd) return console.log("Usage: /obsidian-run <command-id>");
      const res = await runObsidianCommand(cmd);
      console.log(JSON.stringify(res, null, 2));
    },
  });

  pi.registerCommand("obsidian-settings", {
    description: "Open Obsidian settings pane: /obsidian-settings",
    handler: async () => {
      const res = await openObsidianSettings();
      console.log(JSON.stringify(res, null, 2));
    },
  });

  pi.registerCommand("obsidian-install", {
    description: "Install plugin from GitHub: /obsidian-install <github-url>",
    handler: async (args) => {
      const url = args?.trim();
      if (!url) return console.log("Usage: /obsidian-install <github-url>");
      const vaultDir = findVaultPath();
      const res = await installPluginFromGitHub(vaultDir, url);
      console.log(JSON.stringify(res, null, 2));
    },
  });

  pi.registerCommand("obsidian-note-links", {
    description: "Inspect links and backlinks of note: /obsidian-note-links <file>",
    handler: async (args) => {
      const file = args?.trim();
      if (!file) return console.log("Usage: /obsidian-note-links <file>");
      const vaultDir = findVaultPath();
      const res = await getNoteLinks(vaultDir, file);
      console.log(JSON.stringify(res, null, 2));
    },
  });

  pi.registerCommand("obsidian-all-links", {
    description: "View link graph and stats across entire vault: /obsidian-all-links",
    handler: async () => {
      const vaultDir = findVaultPath();
      const res = await buildVaultLinkGraph(vaultDir);
      console.log(JSON.stringify(res, null, 2));
    },
  });
}
