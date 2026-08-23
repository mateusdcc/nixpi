import https from "node:https";
import http from "node:http";
import { exec } from "node:child_process";

export function getClientConfig(overrideUrl, overrideKey) {
  const url = overrideUrl || process.env.OBSIDIAN_REST_API_URL || "https://127.0.0.1:27124";
  const apiKey = overrideKey || process.env.OBSIDIAN_API_KEY || process.env.OBSIDIAN_REST_API_KEY || "";
  return { url: url.replace(/\/+$/, ""), apiKey };
}

export function buildHeaders(apiKey) {
  const headers = { "Content-Type": "application/json" };
  if (apiKey) headers.Authorization = `Bearer ${apiKey}`;
  return headers;
}

export function executeHttpRequest(targetUrl, options = {}) {
  return new Promise((resolve, reject) => {
    const urlObj = new URL(targetUrl);
    const transport = urlObj.protocol === "https:" ? https : http;
    const reqOptions = {
      method: options.method || "GET",
      headers: options.headers || {},
      rejectUnauthorized: false,
    };
    const req = transport.request(urlObj, reqOptions, (res) => {
      let data = "";
      res.on("data", (chunk) => { data += chunk; });
      res.on("end", () => resolve({ status: res.statusCode, data }));
    });
    req.on("error", reject);
    if (options.body) req.write(typeof options.body === "string" ? options.body : JSON.stringify(options.body));
    req.end();
  });
}

export async function openNoteInApp(filePath, vaultName, clientConfig = {}) {
  const { url, apiKey } = getClientConfig(clientConfig.url, clientConfig.apiKey);
  try {
    const encoded = encodeURIComponent(filePath);
    const res = await executeHttpRequest(`${url}/open/${encoded}`, {
      method: "POST",
      headers: buildHeaders(apiKey),
    });
    if (res.status >= 200 && res.status < 300) {
      return { success: true, method: "rest-api" };
    }
  } catch {
    // Fall back to system URI
  }
  return openViaObsidianUri(filePath, vaultName);
}

export function openViaObsidianUri(filePath, vaultName) {
  return new Promise((resolve) => {
    const params = new URLSearchParams();
    if (vaultName) params.append("vault", vaultName);
    params.append("file", filePath);
    const uri = `obsidian://open?${params.toString()}`;
    const cmd = process.platform === "darwin" ? `open "${uri}"` : `xdg-open "${uri}"`;
    exec(cmd, (err) => {
      resolve({ success: !err, method: "uri", uri, error: err?.message });
    });
  });
}

export async function listObsidianCommands(clientConfig = {}) {
  const { url, apiKey } = getClientConfig(clientConfig.url, clientConfig.apiKey);
  try {
    const res = await executeHttpRequest(`${url}/commands/`, {
      method: "GET",
      headers: buildHeaders(apiKey),
    });
    if (res.status === 200) {
      const parsed = JSON.parse(res.data);
      return { success: true, commands: parsed.commands || parsed };
    }
    return { success: false, error: `HTTP ${res.status}: ${res.data}` };
  } catch (err) {
    return { success: false, error: err.message, fallbackCommands: getCoreFallbackCommands() };
  }
}

export async function runObsidianCommand(commandId, clientConfig = {}) {
  const { url, apiKey } = getClientConfig(clientConfig.url, clientConfig.apiKey);
  const encodedId = encodeURIComponent(commandId);
  const res = await executeHttpRequest(`${url}/commands/${encodedId}/`, {
    method: "POST",
    headers: buildHeaders(apiKey),
  });
  const success = res.status >= 200 && res.status < 300;
  return { success, status: res.status, output: res.data };
}

export function splitObsidianScreen(direction = "vertical", clientConfig = {}) {
  const isHoriz = direction.toLowerCase().startsWith("h") || direction.toLowerCase() === "down";
  const cmd = isHoriz ? "workspace:split-horizontal" : "workspace:split-vertical";
  return runObsidianCommand(cmd, clientConfig);
}

export function openObsidianSettings(clientConfig = {}) {
  return runObsidianCommand("app:open-settings", clientConfig);
}

export function getCoreFallbackCommands() {
  return [
    { id: "app:open-settings", name: "Open settings" },
    { id: "app:reload", name: "Reload app without saving" },
    { id: "workspace:split-vertical", name: "Split right" },
    { id: "workspace:split-horizontal", name: "Split down" },
    { id: "workspace:close", name: "Close active pane" },
    { id: "workspace:toggle-left-sidebar", name: "Toggle left sidebar" },
    { id: "workspace:toggle-right-sidebar", name: "Toggle right sidebar" },
    { id: "editor:toggle-source", name: "Toggle Live Preview / Source mode" },
    { id: "file-explorer:open", name: "Open file explorer" },
    { id: "graph:open", name: "Open graph view" }
  ];
}
