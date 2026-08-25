const { Plugin, Modal, Notice } = require("obsidian");
const http = require("http");
const fs = require("fs");
const path = require("path");

class DiagnosticProbeModal extends Modal {
  constructor(app, options, resolve) {
    super(app);
    this.options = options || {};
    this.resolve = resolve;
    this.submitted = false;
    this.answers = {};
  }

  onOpen() {
    const { contentEl } = this;
    contentEl.empty();
    contentEl.style.maxHeight = "80vh";
    contentEl.style.overflowY = "auto";

    const header = contentEl.createEl("h2", { text: this.options.title || "Diagnostic Knowledge Probe" });
    header.style.marginBottom = "8px";

    if (this.options.description) {
      const desc = contentEl.createEl("p", { text: this.options.description });
      desc.style.color = "var(--text-muted)";
      desc.style.marginBottom = "16px";
    }

    const form = contentEl.createEl("form");
    const questions = this.options.questions || [];

    questions.forEach((q, index) => {
      const qBlock = form.createEl("div");
      qBlock.style.marginBottom = "18px";
      qBlock.style.padding = "12px";
      qBlock.style.borderRadius = "6px";
      qBlock.style.backgroundColor = "var(--background-secondary)";

      const tierTag = q.tier ? `[${q.tier.toUpperCase()}] ` : "";
      const qTitle = qBlock.createEl("div", { text: `${index + 1}. ${tierTag}${q.question}` });
      qTitle.style.fontWeight = "bold";
      qTitle.style.marginBottom = "8px";

      const fieldId = q.id || `q_${index + 1}`;

      if (q.type === "choice" && Array.isArray(q.options) && q.options.length > 0) {
        q.options.forEach((opt) => {
          const row = qBlock.createEl("label");
          row.style.display = "block";
          row.style.margin = "4px 0";
          row.style.cursor = "pointer";

          const radio = row.createEl("input", { type: "radio", attr: { name: fieldId, value: opt } });
          radio.style.marginRight = "6px";
          row.createSpan({ text: opt });

          radio.addEventListener("change", () => {
            this.answers[fieldId] = opt;
          });
        });
      } else {
        const textarea = qBlock.createEl("textarea", {
          attr: {
            placeholder: q.placeholder || "Enter your technical analysis / response...",
            rows: q.rows || 3,
          },
        });
        textarea.style.width = "100%";
        textarea.style.boxSizing = "border-box";
        textarea.style.marginTop = "4px";
        textarea.style.resize = "vertical";

        textarea.addEventListener("input", (e) => {
          this.answers[fieldId] = e.target.value;
        });
      }
    });

    const btnRow = form.createEl("div");
    btnRow.style.display = "flex";
    btnRow.style.justifyContent = "flex-end";
    btnRow.style.gap = "10px";
    btnRow.style.marginTop = "16px";

    btnRow.createEl("button", {
      type: "submit",
      text: this.options.submitText || "Submit Diagnostic Assessment",
      cls: "mod-cta",
    });

    form.addEventListener("submit", (e) => {
      e.preventDefault();
      this.submitted = true;
      new Notice("Diagnostic responses submitted to Pi");
      this.close();
      this.resolve({ success: true, submitted: true, answers: this.answers });
    });
  }

  onClose() {
    const { contentEl } = this;
    contentEl.empty();
    if (!this.submitted) {
      this.resolve({ success: false, submitted: false, error: "Modal closed by user", answers: this.answers });
    }
  }
}

module.exports = class PiBridgePlugin extends Plugin {
  async onload() {
    this.port = 27125;
    this.startServer();
    this.registerCodeBlockProcessors();
  }

  onunload() {
    if (this.server) {
      this.server.close();
      this.server = null;
    }
  }

  registerCodeBlockProcessors() {
    // 1. In-Note Quiz Processor
    this.registerMarkdownCodeBlockProcessor("pi-quiz", (source, el, ctx) => {
      const config = this.parseSimpleYaml(source);
      el.empty();

      const card = el.createEl("div", { cls: "pi-quiz-container" });
      card.style.border = "1px solid var(--interactive-accent)";
      card.style.borderRadius = "8px";
      card.style.padding = "14px";
      card.style.margin = "14px 0";
      card.style.backgroundColor = "var(--background-secondary)";

      const badge = card.createEl("div", { text: `[PI QUIZ] ${config.title || config.id || "Knowledge Check"}` });
      badge.style.fontSize = "11px";
      badge.style.fontWeight = "bold";
      badge.style.color = "var(--interactive-accent)";
      badge.style.textTransform = "uppercase";
      badge.style.marginBottom = "6px";

      const questionText = card.createEl("div", { text: config.question || config.prompt || "Answer the following question:" });
      questionText.style.fontWeight = "600";
      questionText.style.marginBottom = "10px";
      questionText.style.lineHeight = "1.4";

      const textarea = card.createEl("textarea", {
        attr: {
          placeholder: config.placeholder || "Type your analysis / solution here and click Submit to send to Pi...",
          rows: config.rows ? parseInt(config.rows, 10) : 4,
        },
      });
      textarea.style.width = "100%";
      textarea.style.boxSizing = "border-box";
      textarea.style.marginBottom = "10px";
      textarea.style.borderRadius = "4px";
      textarea.style.resize = "vertical";

      const btnRow = card.createEl("div");
      btnRow.style.display = "flex";
      btnRow.style.justifyContent = "space-between";
      btnRow.style.alignItems = "center";

      const statusSpan = btnRow.createEl("span", { text: "" });
      statusSpan.style.fontSize = "12px";
      statusSpan.style.color = "var(--text-muted)";

      const submitBtn = btnRow.createEl("button", {
        text: "Send to Pi for Verification",
        cls: "mod-cta",
      });

      submitBtn.addEventListener("click", async () => {
        const answer = textarea.value.trim();
        if (!answer) {
          new Notice("Please enter an answer before submitting.");
          return;
        }

        submitBtn.disabled = true;
        submitBtn.setText("Sending to Pi...");

        try {
          const payload = {
            notePath: ctx.sourcePath || "",
            quizId: config.id || `quiz-${Date.now()}`,
            title: config.title || "",
            question: config.question || "",
            answer: answer,
            timestamp: new Date().toISOString(),
          };

          const res = await fetch(`http://127.0.0.1:${this.port}/quiz/submit`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload),
          });

          if (res.ok) {
            submitBtn.setText("Answer Sent to Pi");
            submitBtn.style.backgroundColor = "var(--color-green)";
            statusSpan.setText("Queued for Pi verification");
            new Notice("Quiz response submitted to Pi for verification.");
          } else {
            throw new Error(`Server returned ${res.status}`);
          }
        } catch (err) {
          submitBtn.disabled = false;
          submitBtn.setText("Retry Sending to Pi");
          new Notice(`Failed to send quiz to Pi: ${err.message}`);
        }
      });
    });

    // 2. In-Note Section Action / Query Processor
    this.registerMarkdownCodeBlockProcessor("pi-action", (source, el, ctx) => {
      const config = this.parseSimpleYaml(source);
      el.empty();

      const actionBox = el.createEl("div");
      actionBox.style.margin = "10px 0";
      actionBox.style.display = "flex";
      actionBox.style.alignItems = "center";
      actionBox.style.gap = "8px";

      const btn = actionBox.createEl("button", {
        text: config.label || "Ask Pi About This Section",
      });
      btn.style.fontSize = "12px";
      btn.style.padding = "4px 10px";

      const infoSpan = actionBox.createEl("span", {
        text: config.section ? `Section: ${config.section}` : "",
      });
      infoSpan.style.fontSize = "11px";
      infoSpan.style.color = "var(--text-muted)";

      btn.addEventListener("click", async () => {
        try {
          const payload = {
            notePath: ctx.sourcePath || "",
            action: config.label || "Ask Pi",
            prompt: config.prompt || "",
            section: config.section || "",
            timestamp: new Date().toISOString(),
          };

          await fetch(`http://127.0.0.1:${this.port}/action/submit`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload),
          });

          new Notice(`Action sent to Pi: ${config.label || "Query"}`);
        } catch (err) {
          new Notice(`Action failed: ${err.message}`);
        }
      });
    });
  }

  parseSimpleYaml(str) {
    const out = {};
    const lines = str.split("\n");
    for (const line of lines) {
      const trimmed = line.trim();
      if (!trimmed || trimmed.startsWith("#")) continue;
      const idx = trimmed.indexOf(":");
      if (idx !== -1) {
        const k = trimmed.substring(0, idx).trim();
        let v = trimmed.substring(idx + 1).trim();
        if ((v.startsWith('"') && v.endsWith('"')) || (v.startsWith("'") && v.endsWith("'"))) {
          v = v.substring(1, v.length - 1);
        }
        out[k] = v;
      }
    }
    return out;
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
    if (pathname === "/modal" || pathname === "/probe") {
      return new Promise((resolve) => {
        new DiagnosticProbeModal(this.app, body, resolve).open();
      });
    }
    if (pathname === "/notice") {
      new Notice(body.message || params.get("message") || "", body.duration || 5000);
      return { success: true };
    }
    if (pathname === "/quiz/submit") return this.handleQuizSubmit(body);
    if (pathname === "/quiz/pending" || pathname === "/quiz/submissions") return this.handleQuizPending();
    if (pathname === "/quiz/feedback") return this.handleQuizFeedback(body);
    if (pathname === "/action/submit") return this.handleActionSubmit(body);

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

  handleQuizSubmit(body) {
    const basePath = this.app.vault.adapter.basePath || process.cwd();
    const piDir = path.join(basePath, ".pi");
    fs.mkdirSync(piDir, { recursive: true });
    const submissionsFile = path.join(piDir, "quiz_submissions.json");

    let list = [];
    if (fs.existsSync(submissionsFile)) {
      try { list = JSON.parse(fs.readFileSync(submissionsFile, "utf-8")); } catch {}
    }
    list.push({ ...body, receivedAt: new Date().toISOString() });
    fs.writeFileSync(submissionsFile, JSON.stringify(list, null, 2), "utf-8");
    return { success: true, count: list.length, latest: body };
  }

  handleQuizPending() {
    const basePath = this.app.vault.adapter.basePath || process.cwd();
    const submissionsFile = path.join(basePath, ".pi", "quiz_submissions.json");
    if (fs.existsSync(submissionsFile)) {
      try {
        const list = JSON.parse(fs.readFileSync(submissionsFile, "utf-8"));
        return { success: true, submissions: list };
      } catch {}
    }
    return { success: true, submissions: [] };
  }

  handleQuizFeedback(body) {
    const basePath = this.app.vault.adapter.basePath || process.cwd();
    const piDir = path.join(basePath, ".pi");
    fs.mkdirSync(piDir, { recursive: true });
    const feedbackFile = path.join(piDir, "quiz_feedback.json");

    let list = [];
    if (fs.existsSync(feedbackFile)) {
      try { list = JSON.parse(fs.readFileSync(feedbackFile, "utf-8")); } catch {}
    }
    list.push({ ...body, feedbackAt: new Date().toISOString() });
    fs.writeFileSync(feedbackFile, JSON.stringify(list, null, 2), "utf-8");

    if (body.message || body.feedback) {
      new Notice(`[Pi Verification] ${body.title || "Quiz Evaluated"}: ${body.feedback || body.message}`, 8000);
    }
    return { success: true };
  }

  handleActionSubmit(body) {
    const basePath = this.app.vault.adapter.basePath || process.cwd();
    const piDir = path.join(basePath, ".pi");
    fs.mkdirSync(piDir, { recursive: true });
    const actionsFile = path.join(piDir, "action_requests.json");

    let list = [];
    if (fs.existsSync(actionsFile)) {
      try { list = JSON.parse(fs.readFileSync(actionsFile, "utf-8")); } catch {}
    }
    list.push({ ...body, receivedAt: new Date().toISOString() });
    fs.writeFileSync(actionsFile, JSON.stringify(list, null, 2), "utf-8");
    return { success: true, count: list.length, latest: body };
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
