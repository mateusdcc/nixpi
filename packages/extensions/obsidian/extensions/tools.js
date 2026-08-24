import { findVaultPath } from "./vault.js";
import {
  openNoteInApp,
  splitObsidianScreen,
  listObsidianCommands,
  runObsidianCommand,
  openObsidianSettings,
  getObsidianLayout,
  takeObsidianScreenshot,
} from "./client.js";
import { readSettings, updateSettings } from "./settings.js";
import { getNoteLinks, buildVaultLinkGraph } from "./links.js";
import { installPluginFromGitHub } from "./installer.js";
import { ensureCompanionPlugin } from "./bridge.js";

function respond(data) {
  const text = typeof data === "string" ? data : JSON.stringify(data, null, 2);
  return { content: [{ type: "text", text }] };
}

export function registerObsidianTools(pi) {
  if (!pi || !pi.registerTool) return;

  pi.registerTool({
    name: "obsidian_take_screenshot",
    label: "Obsidian Take Screenshot",
    description: "Take an in-app screenshot of Obsidian (window or active editor pane) without OS permissions",
    parameters: {
      type: "object",
      properties: {
        mode: {
          type: "string",
          enum: ["window", "active_pane"],
          default: "window",
          description: "Capture mode: 'window' for full app or 'active_pane' for active editor pane",
        },
        filename: { type: "string", description: "Optional PNG filename" },
      },
    },
    async execute(id, params) {
      const res = await takeObsidianScreenshot({
        mode: params?.mode || "window",
        filename: params?.filename,
      });
      return respond(res);
    },
  });

  pi.registerTool({
    name: "obsidian_get_layout",
    label: "Obsidian Get Layout",
    description: "Get the current workspace layout of Obsidian (open panes, active note, splits, tabs, sidebars)",
    parameters: {
      type: "object",
      properties: { vault: { type: "string", description: "Vault path override" } },
    },
    async execute(id, params) {
      const vaultDir = findVaultPath(params?.vault);
      const res = await getObsidianLayout({}, vaultDir);
      return respond(res);
    },
  });

  pi.registerTool({
    name: "obsidian_setup_bridge",
    label: "Obsidian Setup Bridge",
    description: "Install and enable the Pi Bridge companion plugin in the Obsidian vault",
    parameters: {
      type: "object",
      properties: { vault: { type: "string", description: "Vault path override" } },
    },
    async execute(id, params) {
      const vaultDir = findVaultPath(params?.vault);
      const res = await ensureCompanionPlugin(vaultDir);
      return respond(res);
    },
  });

  pi.registerTool({
    name: "obsidian_open_note",
    label: "Obsidian Open Note",
    description: "Open a note in the Obsidian application",
    parameters: {
      type: "object",
      properties: {
        file: { type: "string", description: "Relative or absolute note path" },
        vault: { type: "string", description: "Vault name or directory path (optional)" },
      },
      required: ["file"],
    },
    async execute(id, params) {
      const vaultDir = findVaultPath(params?.vault);
      const res = await openNoteInApp(params.file, vaultDir);
      return respond(res);
    },
  });

  pi.registerTool({
    name: "obsidian_split_screen",
    label: "Obsidian Split Screen",
    description: "Split active editor pane vertically or horizontally",
    parameters: {
      type: "object",
      properties: {
        direction: {
          type: "string",
          enum: ["vertical", "horizontal"],
          default: "vertical",
          description: "Split direction: vertical (split right) or horizontal (split down)",
        },
      },
    },
    async execute(id, params) {
      const res = await splitObsidianScreen(params?.direction || "vertical");
      return respond(res);
    },
  });

  pi.registerTool({
    name: "obsidian_list_commands",
    label: "Obsidian List Commands",
    description: "List all available Obsidian commands and their IDs",
    parameters: { type: "object", properties: {} },
    async execute() {
      const res = await listObsidianCommands();
      return respond(res);
    },
  });

  pi.registerTool({
    name: "obsidian_run_command",
    label: "Obsidian Run Command",
    description: "Execute a command in Obsidian by command ID",
    parameters: {
      type: "object",
      properties: {
        command_id: { type: "string", description: "Obsidian command identifier" },
      },
      required: ["command_id"],
    },
    async execute(id, params) {
      const res = await runObsidianCommand(params.command_id);
      return respond(res);
    },
  });

  pi.registerTool({
    name: "obsidian_open_settings",
    label: "Obsidian Open Settings",
    description: "Open the Obsidian settings dialog",
    parameters: { type: "object", properties: {} },
    async execute() {
      const res = await openObsidianSettings();
      return respond(res);
    },
  });

  pi.registerTool({
    name: "obsidian_get_settings",
    label: "Obsidian Get Settings",
    description: "Read Obsidian vault settings (app, appearance, community-plugins, or plugin:<id>)",
    parameters: {
      type: "object",
      properties: {
        config_type: { type: "string", default: "app", description: "Config type or plugin ID" },
        vault: { type: "string", description: "Vault path override" },
      },
    },
    async execute(id, params) {
      const vaultDir = findVaultPath(params?.vault);
      const res = await readSettings(vaultDir, params?.config_type || "app");
      return respond(res);
    },
  });

  pi.registerTool({
    name: "obsidian_change_settings",
    label: "Obsidian Change Settings",
    description: "Update or merge settings in Obsidian config files",
    parameters: {
      type: "object",
      properties: {
        config_type: { type: "string", description: "Config type" },
        updates: { type: "object", description: "Key-value pairs to update/merge" },
        vault: { type: "string", description: "Vault path override" },
      },
      required: ["config_type", "updates"],
    },
    async execute(id, params) {
      const vaultDir = findVaultPath(params?.vault);
      const res = await updateSettings(vaultDir, params.config_type, params.updates);
      return respond(res);
    },
  });

  pi.registerTool({
    name: "obsidian_install_github_plugin",
    label: "Obsidian Install GitHub Plugin",
    description: "Download and install an Obsidian community plugin directly from a GitHub link",
    parameters: {
      type: "object",
      properties: {
        github_url: { type: "string", description: "GitHub URL or owner/repo" },
        vault: { type: "string", description: "Vault path override" },
      },
      required: ["github_url"],
    },
    async execute(id, params) {
      const vaultDir = findVaultPath(params?.vault);
      const res = await installPluginFromGitHub(vaultDir, params.github_url);
      return respond(res);
    },
  });

  pi.registerTool({
    name: "obsidian_note_links",
    label: "Obsidian Note Links",
    description: "Inspect outgoing links, wikilinks, embeds, tags, and backlinks for a note",
    parameters: {
      type: "object",
      properties: {
        file: { type: "string", description: "Relative or absolute note path" },
        vault: { type: "string", description: "Vault path override" },
      },
      required: ["file"],
    },
    async execute(id, params) {
      const vaultDir = findVaultPath(params?.vault);
      const res = await getNoteLinks(vaultDir, params.file);
      return respond(res);
    },
  });

  pi.registerTool({
    name: "obsidian_all_links",
    label: "Obsidian All Links",
    description: "Scan the entire Obsidian vault and build the complete link graph and stats",
    parameters: {
      type: "object",
      properties: { vault: { type: "string", description: "Vault path override" } },
    },
    async execute(id, params) {
      const vaultDir = findVaultPath(params?.vault);
      const res = await buildVaultLinkGraph(vaultDir);
      return respond(res);
    },
  });
}
