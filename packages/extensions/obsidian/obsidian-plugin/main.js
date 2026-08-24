const { Plugin } = require("obsidian");
const http = require("http");
const fs = require("fs");
const path = require("path");

module.exports = class PiBridgePlugin extends Plugin {
  async onload() {
    this.port = 27125;
    this.startServer();
  }

  onunload() {
    if (this.server) {
      this.server.close();
      this.server = null;
    }
  }

  startServer() {
    this.server = http.createServer(async (req, res) => {
      this.setCorsHeaders(res);
      if (req.method === "OPTIONS") {
        res.writeHead(204);
        return res.end();
      }
      this.handleRequest(req, res);
    });
    this.server.on("error", (err) => console.error("[Pi Bridge] Server error:", err.message));
    this.server.listen(this.port, "127.0.0.1", () => {
      console.log(`[Pi Bridge] Server listening on http://127.0.0.1:${this.port}`);
    });
  }

  setCorsHeaders(res) {
    res.setHeader("Access-Control-Allow-Origin", "*");
    res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
    res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
  }

  handleRequest(req, res) {
    let body = "";
    req.on("data", (chunk) => { body += chunk; });
    req.on("end", async () => {
      let jsonBody = {};
      try { if (body) jsonBody = JSON.parse(body); } catch {}
      const url = new URL(req.url, `http://localhost:${this.port}`);
      try {
        const result = await this.route(req.method, url.pathname, jsonBody, url.searchParams);
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify(result));
      } catch (err) {
        res.writeHead(500, { "Content-Type": "application/json" });
        res.end(JSON.stringify({ success: false, error: err.message }));
      }
    });
  }

  async route(method, pathname, body, params) {
    if (pathname === "/" || pathname === "/status") return this.handleStatus();
    if (pathname === "/screenshot") return this.handleScreenshot(body, params);
    if (pathname === "/layout" || pathname === "/workspace/layout") return this.handleLayout();
    if (pathname === "/open") return this.handleOpen(body, params);
    if (pathname === "/split") return this.handleSplit(body, params);
    if (pathname === "/commands") return this.handleListCommands();
    if (pathname.startsWith("/commands/") || pathname === "/command") return this.handleRunCommand(pathname, body, params);
    if (pathname === "/settings" || pathname === "/settings/open") return this.handleOpenSettings(body);
    if (pathname === "/metadata") return this.handleMetadata(body, params);
    throw new Error(`Route not found: ${method} ${pathname}`);
  }

  handleStatus() {
    const cmdCount = Object.keys(this.app.commands.commands || {}).length;
    return { status: "ok", vault: this.app.vault.getName(), commandsCount: cmdCount };
  }

  async handleScreenshot(body, params) {
    const electron = require("electron");
    const win = electron.remote?.getCurrentWindow ? electron.remote.getCurrentWindow() : null;
    const webContents = electron.remote?.getCurrentWebContents ? electron.remote.getCurrentWebContents() : win?.webContents;
    if (!webContents) throw new Error("Obsidian webContents not accessible");

    const mode = body.mode || params.get("mode") || "window";
    let rect = body.rect;
    if (mode === "active_pane" && typeof document !== "undefined") {
      const activeEl = document.querySelector(".workspace-leaf.mod-active") || document.querySelector(".workspace-leaf");
      if (activeEl) {
        const domRect = activeEl.getBoundingClientRect();
        rect = {
          x: Math.round(domRect.x),
          y: Math.round(domRect.y),
          width: Math.round(domRect.width),
          height: Math.round(domRect.height),
        };
      }
    }

    const img = await webContents.capturePage(rect);
    const pngBuffer = img.toPNG();
    const basePath = this.app.vault.adapter.basePath || process.cwd();
    const outDir = path.join(basePath, ".pi", "screenshots");
    fs.mkdirSync(outDir, { recursive: true });

    const filename = body.filename || `screenshot-${Date.now()}.png`;
    const targetPath = path.join(outDir, filename);
    fs.writeFileSync(targetPath, pngBuffer);

    return {
      success: true,
      path: targetPath,
      filename,
      mode,
      size: { width: img.getSize().width, height: img.getSize().height },
      bytes: pngBuffer.length,
      method: "obsidian-capturePage",
    };
  }

  handleLayout() {
    const layout = this.app.workspace.getLayout();
    const activeFile = this.app.workspace.getActiveFile()?.path || null;
    return { success: true, activeFile, summary: this.summarizeLayout(layout, activeFile), layout };
  }

  summarizeLayout(layout, activeFile) {
    const mainPanes = [];
    this.extractLeaves(layout.main, mainPanes, layout.active);
    return {
      activeFile,
      activeLeafId: layout.active,
      leftSidebarCollapsed: layout.left?.collapsed ?? true,
      rightSidebarCollapsed: layout.right?.collapsed ?? true,
      panesCount: mainPanes.length,
      panes: mainPanes,
    };
  }

  extractLeaves(node, list, activeId) {
    if (!node) return;
    if (node.type === "leaf") {
      list.push({
        id: node.id,
        type: node.state?.type || "unknown",
        file: node.state?.state?.file || null,
        title: node.state?.title || null,
        isActive: node.id === activeId,
      });
    }
    if (node.children) {
      for (const child of node.children) this.extractLeaves(child, list, activeId);
    }
  }

  async handleOpen(body, params) {
    const file = body.file || params.get("file");
    if (!file) throw new Error("Missing 'file' parameter");
    const direction = body.direction;
    const newLeaf = body.newLeaf ?? false;

    let leaf;
    if (direction === "vertical") leaf = this.app.workspace.getLeaf("split", "vertical");
    else if (direction === "horizontal") leaf = this.app.workspace.getLeaf("split", "horizontal");
    else if (newLeaf) leaf = this.app.workspace.getLeaf("tab");
    else leaf = this.app.workspace.getLeaf(false);

    const tfile = this.app.metadataCache.getFirstLinkpathDest(file, "") ||
      this.app.vault.getAbstractFileByPath(file.endsWith(".md") ? file : `${file}.md`);
    if (tfile) await leaf.openFile(tfile);
    else await this.app.workspace.openLinkText(file, "", newLeaf);
    return { success: true, file };
  }

  handleSplit(body, params) {
    const direction = body.direction || params.get("direction") || "vertical";
    const isHoriz = direction === "horizontal" || direction === "down";
    const cmd = isHoriz ? "workspace:split-horizontal" : "workspace:split-vertical";
    this.app.commands.executeCommandById(cmd);
    return { success: true, direction };
  }

  handleListCommands() {
    const cmds = Object.values(this.app.commands.commands || {}).map((c) => ({
      id: c.id,
      name: c.name,
    }));
    return { success: true, commands: cmds };
  }

  handleRunCommand(pathname, body, params) {
    let cmdId = body.command_id || body.commandId || params.get("command_id");
    if (!cmdId && pathname.startsWith("/commands/")) {
      cmdId = decodeURIComponent(pathname.replace("/commands/", "").replace(/\/$/, ""));
    }
    if (!cmdId) throw new Error("Missing command ID");
    const res = this.app.commands.executeCommandById(cmdId);
    return { success: res !== false, commandId: cmdId };
  }

  handleOpenSettings(body) {
    this.app.setting.open();
    if (body.tabId) this.app.setting.openTabById(body.tabId);
    return { success: true };
  }

  handleMetadata(body, params) {
    const file = body.file || params.get("file");
    if (!file) throw new Error("Missing 'file' parameter");
    const tfile = this.app.metadataCache.getFirstLinkpathDest(file, "") ||
      this.app.vault.getAbstractFileByPath(file.endsWith(".md") ? file : `${file}.md`);
    if (!tfile) throw new Error(`Note not found: ${file}`);
    const cache = this.app.metadataCache.getFileCache(tfile);
    return { success: true, file: tfile.path, cache };
  }
};
