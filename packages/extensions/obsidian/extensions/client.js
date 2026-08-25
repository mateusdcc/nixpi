import fs from "node:fs";
import https from "node:https";
import http from "node:http";
import path from "node:path";
import { exec } from "node:child_process";

export function getClientConfig(overrideUrl, overrideKey) {
  const url = overrideUrl || process.env.OBSIDIAN_REST_API_URL || "http://127.0.0.1:27125";
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

export async function getObsidianLayout(clientConfig = {}, vaultDir = null) {
  const { url, apiKey } = getClientConfig(clientConfig.url, clientConfig.apiKey);
  try {
    const res = await executeHttpRequest(`${url}/layout`, {
      method: "GET",
      headers: buildHeaders(apiKey),
    });
    if (res.status === 200) {
      return JSON.parse(res.data);
    }
  } catch {}

  if (vaultDir) {
    const wsFile = path.join(vaultDir, ".obsidian", "workspace.json");
    if (fs.existsSync(wsFile)) {
      try {
        const raw = await fs.promises.readFile(wsFile, "utf-8");
        const layout = JSON.parse(raw);
        return { success: true, method: "workspace.json", layout };
      } catch {}
    }
  }
  return { success: false, error: "Unable to retrieve Obsidian workspace layout" };
}

export async function takeObsidianScreenshot(options = {}, clientConfig = {}) {
  const { url, apiKey } = getClientConfig(clientConfig.url, clientConfig.apiKey);
  try {
    const res = await executeHttpRequest(`${url}/screenshot`, {
      method: "POST",
      headers: buildHeaders(apiKey),
      body: options,
    });
    if (res.status === 200) {
      return JSON.parse(res.data);
    }
  } catch (err) {
    return { success: false, error: err.message };
  }
  return { success: false, error: "Failed to take Obsidian screenshot via Bridge" };
}

export async function openNoteInApp(filePath, vaultPathOrName, clientConfig = {}) {
  const { url, apiKey } = getClientConfig(clientConfig.url, clientConfig.apiKey);
  try {
    const resBridge = await executeHttpRequest(`${url}/open`, {
      method: "POST",
      headers: buildHeaders(apiKey),
      body: { file: filePath },
    });
    if (resBridge.status >= 200 && resBridge.status < 300) return { success: true, method: "bridge" };
  } catch {}

  try {
    const encoded = encodeURIComponent(filePath);
    const res = await executeHttpRequest(`${url}/open/${encoded}`, {
      method: "POST",
      headers: buildHeaders(apiKey),
    });
    if (res.status >= 200 && res.status < 300) return { success: true, method: "rest-api" };
  } catch {}

  return openViaObsidianUri(filePath, vaultPathOrName);
}

export function openViaObsidianUri(filePath, vaultPathOrName) {
  return new Promise((resolve) => {
    const params = new URLSearchParams();
    if (path.isAbsolute(filePath)) {
      params.append("path", filePath);
    } else {
      if (vaultPathOrName) {
        const cleanVault = vaultPathOrName.includes("/") || vaultPathOrName.includes("\\")
          ? path.basename(path.resolve(vaultPathOrName))
          : vaultPathOrName;
        params.append("vault", cleanVault);
      }
      params.append("file", filePath);
    }
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
    const res = await executeHttpRequest(`${url}/commands`, {
      method: "GET",
      headers: buildHeaders(apiKey),
    });
    if (res.status === 200) {
      const parsed = JSON.parse(res.data);
      return { success: true, commands: parsed.commands || parsed };
    }
  } catch {}
  return { success: false, fallbackCommands: getCoreFallbackCommands() };
}

export async function runObsidianCommand(commandId, clientConfig = {}) {
  const { url, apiKey } = getClientConfig(clientConfig.url, clientConfig.apiKey);
  try {
    const encodedId = encodeURIComponent(commandId);
    const res = await executeHttpRequest(`${url}/commands/${encodedId}`, {
      method: "POST",
      headers: buildHeaders(apiKey),
      body: { command_id: commandId },
    });
    if (res.status >= 200 && res.status < 300) {
      return { success: true, status: res.status, output: res.data };
    }
  } catch (err) {
    return { success: false, error: err.message };
  }
  return { success: false, error: "Command execution failed" };
}

export async function splitObsidianScreen(direction = "vertical", clientConfig = {}) {
  const { url, apiKey } = getClientConfig(clientConfig.url, clientConfig.apiKey);
  try {
    const res = await executeHttpRequest(`${url}/split`, {
      method: "POST",
      headers: buildHeaders(apiKey),
      body: { direction },
    });
    if (res.status >= 200 && res.status < 300) return { success: true, method: "bridge", direction };
  } catch {}

  const isHoriz = direction.toLowerCase().startsWith("h") || direction.toLowerCase() === "down";
  const cmd = isHoriz ? "workspace:split-horizontal" : "workspace:split-vertical";
  return runObsidianCommand(cmd, clientConfig);
}

export async function openObsidianSettings(clientConfig = {}) {
  const { url, apiKey } = getClientConfig(clientConfig.url, clientConfig.apiKey);
  try {
    const res = await executeHttpRequest(`${url}/settings`, {
      method: "POST",
      headers: buildHeaders(apiKey),
    });
    if (res.status >= 200 && res.status < 300) return { success: true, method: "bridge" };
  } catch {}
  return runObsidianCommand("app:open-settings", clientConfig);
}

export function getCoreFallbackCommands() {
  return [
    { id: "app:open-settings", name: "Open settings" },
    { id: "app:reload", name: "Reload app without saving" },
    { id: "workspace:split-vertical", name: "Split right" },
    { id: "workspace:split-horizontal", name: "Split down" },
    { id: "workspace:close", name: "Close active pane" },
    { id: "app:toggle-left-sidebar", name: "Toggle left sidebar" },
    { id: "app:toggle-right-sidebar", name: "Toggle right sidebar" },
    { id: "editor:toggle-source", name: "Toggle Live Preview / Source mode" },
    { id: "file-explorer:open", name: "Open file explorer" },
    { id: "graph:open", name: "Open graph view" },
  ];
}

export async function promptObsidianModal(modalPayload = {}, clientConfig = {}) {
  const { url, apiKey } = getClientConfig(clientConfig.url, clientConfig.apiKey);
  try {
    const res = await executeHttpRequest(`${url}/modal`, {
      method: "POST",
      headers: buildHeaders(apiKey),
      body: modalPayload,
    });
    if (res.status === 200) {
      return JSON.parse(res.data);
    }
    return { success: false, error: `Bridge returned status ${res.status}: ${res.data}` };
  } catch (err) {
    return { success: false, error: err.message };
  }
}

export async function showObsidianNotice(message, duration = 5000, clientConfig = {}) {
  const { url, apiKey } = getClientConfig(clientConfig.url, clientConfig.apiKey);
  try {
    const res = await executeHttpRequest(`${url}/notice`, {
      method: "POST",
      headers: buildHeaders(apiKey),
      body: { message, duration },
    });
    if (res.status === 200) {
      return JSON.parse(res.data);
    }
  } catch (err) {
    return { success: false, error: err.message };
  }
  return { success: false };
}

export async function getQuizSubmissions(filter = {}, clientConfig = {}) {
  const { url, apiKey } = getClientConfig(clientConfig.url, clientConfig.apiKey);
  try {
    const params = new URLSearchParams();
    if (filter.status) params.append("status", filter.status);
    if (filter.concept_id) params.append("concept_id", filter.concept_id);
    const qs = params.toString() ? `?${params.toString()}` : "";

    const res = await executeHttpRequest(`${url}/quiz/submissions${qs}`, {
      method: "GET",
      headers: buildHeaders(apiKey),
    });
    if (res.status === 200) {
      return JSON.parse(res.data);
    }
    return { success: false, error: `Bridge returned status ${res.status}: ${res.data}` };
  } catch (err) {
    return { success: false, error: err.message };
  }
}

export async function evaluateQuizSubmission(subId, feedbackPayload = {}, clientConfig = {}) {
  const { url, apiKey } = getClientConfig(clientConfig.url, clientConfig.apiKey);
  try {
    const encodedId = encodeURIComponent(subId);
    const res = await executeHttpRequest(`${url}/quiz/submissions/${encodedId}/feedback`, {
      method: "POST",
      headers: buildHeaders(apiKey),
      body: feedbackPayload,
    });
    if (res.status === 200) {
      return JSON.parse(res.data);
    }
    return { success: false, error: `Bridge returned status ${res.status}: ${res.data}` };
  } catch (err) {
    return { success: false, error: err.message };
  }
}

export async function getActionSubmissions(clientConfig = {}) {
  const { url, apiKey } = getClientConfig(clientConfig.url, clientConfig.apiKey);
  try {
    const res = await executeHttpRequest(`${url}/action/submissions`, {
      method: "GET",
      headers: buildHeaders(apiKey),
    });
    if (res.status === 200) {
      return JSON.parse(res.data);
    }
    return { success: false, error: `Bridge returned status ${res.status}: ${res.data}` };
  } catch (err) {
    return { success: false, error: err.message };
  }
}

export async function getMasteryLedger(conceptId = null, clientConfig = {}) {
  const { url, apiKey } = getClientConfig(clientConfig.url, clientConfig.apiKey);
  try {
    const qs = conceptId ? `?concept_id=${encodeURIComponent(conceptId)}` : "";
    const res = await executeHttpRequest(`${url}/learning/mastery${qs}`, {
      method: "GET",
      headers: buildHeaders(apiKey),
    });
    if (res.status === 200) {
      return JSON.parse(res.data);
    }
    return { success: false, error: `Bridge returned status ${res.status}: ${res.data}` };
  } catch (err) {
    return { success: false, error: err.message };
  }
}

export async function updateMasteryLedger(conceptId, objectives = {}, clientConfig = {}) {
  const { url, apiKey } = getClientConfig(clientConfig.url, clientConfig.apiKey);
  try {
    const res = await executeHttpRequest(`${url}/learning/mastery`, {
      method: "POST",
      headers: buildHeaders(apiKey),
      body: { concept_id: conceptId, objectives },
    });
    if (res.status === 200) {
      return JSON.parse(res.data);
    }
    return { success: false, error: `Bridge returned status ${res.status}: ${res.data}` };
  } catch (err) {
    return { success: false, error: err.message };
  }
}



