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
    contentEl.style.maxHeight = "85vh";
    contentEl.style.overflowY = "auto";

    const header = contentEl.createEl("h2", { text: this.options.title || "Multidimensional Diagnostic Probe" });
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

      const dimTag = q.dimension ? `[${q.dimension.toUpperCase()}] ` : (q.tier ? `[${q.tier.toUpperCase()}] ` : "");
      const qTitle = qBlock.createEl("div", { text: `${index + 1}. ${dimTag}${q.question}` });
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
            if (!this.answers[fieldId]) this.answers[fieldId] = {};
            if (typeof this.answers[fieldId] === "object") {
              this.answers[fieldId].answer = opt;
            } else {
              this.answers[fieldId] = { answer: opt };
            }
          });
        });
      } else {
        const textarea = qBlock.createEl("textarea", {
          attr: {
            placeholder: q.placeholder || "Enter your technical explanation / prediction (or write 'I do not know')...",
            rows: q.rows || 3,
          },
        });
        textarea.style.width = "100%";
        textarea.style.boxSizing = "border-box";
        textarea.style.marginTop = "4px";
        textarea.style.resize = "vertical";

        textarea.addEventListener("input", (e) => {
          if (!this.answers[fieldId]) this.answers[fieldId] = {};
          if (typeof this.answers[fieldId] === "object") {
            this.answers[fieldId].answer = e.target.value;
          } else {
            this.answers[fieldId] = { answer: e.target.value };
          }
        });
      }

      // Confidence selector
      const confRow = qBlock.createEl("div");
      confRow.style.marginTop = "8px";
      confRow.style.fontSize = "12px";
      confRow.style.color = "var(--text-muted)";
      confRow.createSpan({ text: "Confidence: " });

      ["High", "Medium", "Low", "Unsure / Guessing"].forEach((level) => {
        const confLabel = confRow.createEl("label");
        confLabel.style.marginRight = "10px";
        confLabel.style.cursor = "pointer";
        const confRadio = confLabel.createEl("input", { type: "radio", attr: { name: `${fieldId}_conf`, value: level.toLowerCase() } });
        confRadio.style.marginRight = "3px";
        confLabel.createSpan({ text: level });

        confRadio.addEventListener("change", () => {
          if (!this.answers[fieldId]) this.answers[fieldId] = {};
          if (typeof this.answers[fieldId] === "object") {
            this.answers[fieldId].confidence = level.toLowerCase();
          } else {
            this.answers[fieldId] = { answer: this.answers[fieldId], confidence: level.toLowerCase() };
          }
        });
      });
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

  getLearningDir() {
    const basePath = this.app.vault.adapter.basePath || process.cwd();
    const learningDir = path.join(basePath, ".pi", "learning");
    fs.mkdirSync(learningDir, { recursive: true });
    return learningDir;
  }

  readJsonFile(filename, defaultVal = []) {
    const filePath = path.join(this.getLearningDir(), filename);
    if (fs.existsSync(filePath)) {
      try { return JSON.parse(fs.readFileSync(filePath, "utf-8")); } catch {}
    }
    return defaultVal;
  }

  writeJsonFile(filename, data) {
    const filePath = path.join(this.getLearningDir(), filename);
    fs.writeFileSync(filePath, JSON.stringify(data, null, 2), "utf-8");
  }

  registerCodeBlockProcessors() {
    // 1. In-Note Quiz Processor
    this.registerMarkdownCodeBlockProcessor("pi-quiz", (source, el, ctx) => {
      const config = this.parseConfig(source);
      el.empty();

      const qId = config.question_id || config.id || `quiz_${Date.now()}`;
      const conceptId = config.concept_id || "general";
      const objId = config.objective_id || "general";
      const qFamily = (config.question_family || "probing").toUpperCase();

      const card = el.createEl("div", { cls: "pi-quiz-container" });
      card.style.border = "1px solid var(--interactive-accent)";
      card.style.borderRadius = "8px";
      card.style.padding = "14px";
      card.style.margin = "14px 0";
      card.style.backgroundColor = "var(--background-secondary)";

      // Header row with family badge & submission status
      const headerRow = card.createEl("div");
      headerRow.style.display = "flex";
      headerRow.style.justifyContent = "space-between";
      headerRow.style.alignItems = "center";
      headerRow.style.marginBottom = "6px";

      const badge = headerRow.createEl("div", { text: `[PI QUIZ: ${qFamily}] ${config.title || qId}` });
      badge.style.fontSize = "11px";
      badge.style.fontWeight = "bold";
      badge.style.color = "var(--interactive-accent)";
      badge.style.textTransform = "uppercase";

      const statusBadge = headerRow.createEl("span", { text: "Unanswered" });
      statusBadge.style.fontSize = "11px";
      statusBadge.style.color = "var(--text-muted)";

      // Question text
      const questionText = card.createEl("div", { text: config.question || config.prompt || "Answer the following probe:" });
      questionText.style.fontWeight = "600";
      questionText.style.marginBottom = "10px";
      questionText.style.lineHeight = "1.4";

      // Input area (choice vs text)
      let currentAnswer = "";
      let currentConfidence = "medium";
      let textarea = null;

      if (config.answer_mode === "choice" && Array.isArray(config.options) && config.options.length > 0) {
        const choiceContainer = card.createEl("div");
        choiceContainer.style.marginBottom = "10px";
        config.options.forEach((opt) => {
          const row = choiceContainer.createEl("label");
          row.style.display = "block";
          row.style.margin = "4px 0";
          row.style.cursor = "pointer";

          const radio = row.createEl("input", { type: "radio", attr: { name: `quiz_${qId}`, value: opt } });
          radio.style.marginRight = "6px";
          row.createSpan({ text: opt });

          radio.addEventListener("change", () => {
            currentAnswer = opt;
          });
        });
      } else {
        textarea = card.createEl("textarea", {
          attr: {
            placeholder: config.placeholder || "Type your explanation, prediction, or derivation here...",
            rows: config.rows ? parseInt(config.rows, 10) : 4,
          },
        });
        textarea.style.width = "100%";
        textarea.style.boxSizing = "border-box";
        textarea.style.marginBottom = "10px";
        textarea.style.borderRadius = "4px";
        textarea.style.resize = "vertical";

        textarea.addEventListener("input", (e) => {
          currentAnswer = e.target.value;
        });
      }

      // Confidence selector
      const confRow = card.createEl("div");
      confRow.style.display = "flex";
      confRow.style.alignItems = "center";
      confRow.style.gap = "8px";
      confRow.style.marginBottom = "10px";
      confRow.style.fontSize = "11px";
      confRow.style.color = "var(--text-muted)";
      confRow.createSpan({ text: "Confidence: " });

      ["High", "Medium", "Low"].forEach((lvl) => {
        const lbl = confRow.createEl("label");
        lbl.style.cursor = "pointer";
        const r = lbl.createEl("input", { type: "radio", attr: { name: `conf_${qId}`, value: lvl.toLowerCase() } });
        r.style.marginRight = "3px";
        if (lvl.toLowerCase() === "medium") r.checked = true;
        lbl.createSpan({ text: lvl });

        r.addEventListener("change", () => {
          currentConfidence = lvl.toLowerCase();
        });
      });

      // Feedback container (durable inline)
      const feedbackBox = card.createEl("div");
      feedbackBox.style.display = "none";
      feedbackBox.style.marginTop = "10px";
      feedbackBox.style.padding = "10px";
      feedbackBox.style.borderRadius = "4px";
      feedbackBox.style.backgroundColor = "var(--background-primary)";
      feedbackBox.style.border = "1px solid var(--background-modifier-border)";

      // Check existing submission and feedback
      const submissions = this.readJsonFile("submissions.json", []);
      const existing = submissions.filter((s) => s.question_id === qId).pop();
      if (existing) {
        if (existing.answer && textarea) textarea.value = existing.answer;
        currentAnswer = existing.answer || "";
        statusBadge.setText(existing.status === "completed" ? "Evaluated" : "Queued for evaluation when Pi is available");
        statusBadge.style.color = existing.status === "completed" ? "var(--color-green)" : "var(--color-yellow)";

        if (existing.feedback) {
          feedbackBox.style.display = "block";
          feedbackBox.empty();
          feedbackBox.createEl("div", { text: `[Evaluation Result: ${existing.feedback.mastery_level || "Recorded"}]`, cls: "pi-feedback-header" });
          feedbackBox.createEl("p", { text: existing.feedback.assessment || existing.feedback.comment || "" });
        }
      }

      // Button Row
      const btnRow = card.createEl("div");
      btnRow.style.display = "flex";
      btnRow.style.justifyContent = "space-between";
      btnRow.style.alignItems = "center";

      const submitBtn = btnRow.createEl("button", {
        text: existing && existing.status === "completed" ? "Resubmit Answer" : "Submit Answer for Evaluation",
        cls: "mod-cta",
      });

      submitBtn.addEventListener("click", async () => {
        const val = textarea ? textarea.value.trim() : currentAnswer.trim();
        if (!val) {
          new Notice("Please enter an answer before submitting.");
          return;
        }

        submitBtn.disabled = true;
        submitBtn.setText("Submitting...");

        const subId = `sub_${conceptId}_${qId}_${Date.now()}`;
        const payload = {
          submission_id: subId,
          note_path: ctx.sourcePath || "",
          concept_id: conceptId,
          objective_id: objId,
          question_id: qId,
          question_family: config.question_family || "probing",
          question: config.question || "",
          answer: val,
          confidence: currentConfidence,
          status: "pending",
          timestamp: new Date().toISOString(),
        };

        try {
          const res = await fetch(`http://127.0.0.1:${this.port}/quiz/submissions`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload),
          });

          if (res.ok) {
            submitBtn.disabled = false;
            submitBtn.setText("Answer Submitted");
            statusBadge.setText("Queued for evaluation when Pi is available");
            statusBadge.style.color = "var(--color-yellow)";
            new Notice("Quiz answer queued for Pi evaluation.");
          } else {
            throw new Error(`Server returned ${res.status}`);
          }
        } catch (err) {
          submitBtn.disabled = false;
          submitBtn.setText("Retry Submission");
          new Notice(`Submission failed: ${err.message}`);
        }
      });
    });

    // 2. In-Note Section Action Processor (Interactive Inquiries)
    this.registerMarkdownCodeBlockProcessor("pi-action", (source, el, ctx) => {
      const config = this.parseConfig(source);
      el.empty();

      const box = el.createEl("div");
      box.style.border = "1px dashed var(--background-modifier-border)";
      box.style.borderRadius = "6px";
      box.style.padding = "10px";
      box.style.margin = "10px 0";
      box.style.backgroundColor = "var(--background-secondary-alt)";

      const titleRow = box.createEl("div");
      titleRow.style.fontSize = "12px";
      titleRow.style.fontWeight = "bold";
      titleRow.style.color = "var(--text-muted)";
      titleRow.style.marginBottom = "6px";
      titleRow.setText(`Ask Pi About: ${config.section || config.label || "This Section"}`);

      const input = box.createEl("textarea", {
        attr: {
          placeholder: config.placeholder || "Type your specific question or request a deeper derivation...",
          rows: 2,
        },
      });
      input.style.width = "100%";
      input.style.boxSizing = "border-box";
      input.style.marginBottom = "8px";
      input.style.fontSize = "12px";

      const btnRow = box.createEl("div");
      btnRow.style.display = "flex";
      btnRow.style.justifyContent = "space-between";
      btnRow.style.alignItems = "center";

      const statusSpan = btnRow.createEl("span", { text: "" });
      statusSpan.style.fontSize = "11px";
      statusSpan.style.color = "var(--text-muted)";

      const askBtn = btnRow.createEl("button", { text: config.label || "Send Question to Pi" });
      askBtn.style.fontSize = "12px";

      askBtn.addEventListener("click", async () => {
        const text = input.value.trim();
        if (!text) {
          new Notice("Please enter a question.");
          return;
        }

        askBtn.disabled = true;
        askBtn.setText("Sending...");

        const payload = {
          action_id: `act_${Date.now()}`,
          note_path: ctx.sourcePath || "",
          section: config.section || "",
          question: text,
          status: "pending",
          timestamp: new Date().toISOString(),
        };

        try {
          const res = await fetch(`http://127.0.0.1:${this.port}/action/submissions`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload),
          });

          if (res.ok) {
            askBtn.disabled = false;
            askBtn.setText("Question Sent");
            statusSpan.setText("Queued for Pi response");
            new Notice("Question sent to Pi.");
          } else {
            throw new Error(`Server returned ${res.status}`);
          }
        } catch (err) {
          askBtn.disabled = false;
          askBtn.setText("Retry");
          new Notice(`Failed: ${err.message}`);
        }
      });
    });
  }

  parseConfig(str) {
    const out = {};
    const lines = str.split("\n");
    let currentKey = null;
    let inArray = false;

    for (const line of lines) {
      const trimmed = line.trim();
      if (!trimmed || trimmed.startsWith("#")) continue;

      if (trimmed.startsWith("- ") && currentKey && inArray) {
        if (!Array.isArray(out[currentKey])) out[currentKey] = [];
        let val = trimmed.substring(2).trim();
        if ((val.startsWith('"') && val.endsWith('"')) || (val.startsWith("'") && val.endsWith("'"))) {
          val = val.substring(1, val.length - 1);
        }
        out[currentKey].push(val);
        continue;
      }

      const idx = trimmed.indexOf(":");
      if (idx !== -1) {
        const k = trimmed.substring(0, idx).trim();
        let v = trimmed.substring(idx + 1).trim();

        if (v === "") {
          currentKey = k;
          inArray = true;
          out[k] = [];
        } else {
          inArray = false;
          currentKey = k;
          if ((v.startsWith('"') && v.endsWith('"')) || (v.startsWith("'") && v.endsWith("'"))) {
            v = v.substring(1, v.length - 1);
          }
          if (v.startsWith("[") && v.endsWith("]")) {
            try {
              out[k] = JSON.parse(v);
            } catch {
              out[k] = v.substring(1, v.length - 1).split(",").map((s) => s.trim().replace(/^['"]|['"]$/g, ""));
            }
          } else {
            out[k] = v;
          }
        }
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

    // Queue & Submissions API
    if (pathname === "/quiz/submissions" && method === "POST") return this.handleQuizSubmissionPost(body);
    if (pathname === "/quiz/submissions" && method === "GET") return this.handleQuizSubmissionList(params);
    if (pathname.startsWith("/quiz/submissions/") && pathname.endsWith("/feedback") && method === "POST") {
      const subId = pathname.split("/")[3];
      return this.handleQuizSubmissionFeedback(subId, body);
    }

    // Section Inquiries API
    if (pathname === "/action/submissions" && method === "POST") return this.handleActionSubmissionPost(body);
    if (pathname === "/action/submissions" && method === "GET") return this.handleActionSubmissionList(params);

    // Mastery Ledger API
    if (pathname === "/learning/mastery" && method === "GET") return this.handleMasteryGet(params);
    if (pathname === "/learning/mastery" && method === "POST") return this.handleMasteryPost(body);

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

  handleQuizSubmissionPost(body) {
    const list = this.readJsonFile("submissions.json", []);
    const subId = body.submission_id || `sub_${Date.now()}`;
    const entry = {
      submission_id: subId,
      note_path: body.note_path || "",
      concept_id: body.concept_id || "",
      objective_id: body.objective_id || "",
      question_id: body.question_id || "",
      question_family: body.question_family || "probing",
      question: body.question || "",
      answer: body.answer || "",
      confidence: body.confidence || "medium",
      status: "pending",
      submitted_at: new Date().toISOString(),
    };

    // Idempotent replace if same question_id and pending
    const existingIdx = list.findIndex((s) => s.question_id === entry.question_id && s.status === "pending");
    if (existingIdx !== -1) {
      list[existingIdx] = entry;
    } else {
      list.push(entry);
    }
    this.writeJsonFile("submissions.json", list);
    return { success: true, submission_id: subId, status: "pending" };
  }

  handleQuizSubmissionList(params) {
    const list = this.readJsonFile("submissions.json", []);
    const statusFilter = params.get("status");
    const conceptFilter = params.get("concept_id");

    let filtered = list;
    if (statusFilter) filtered = filtered.filter((s) => s.status === statusFilter);
    if (conceptFilter) filtered = filtered.filter((s) => s.concept_id === conceptFilter);

    return { success: true, submissions: filtered };
  }

  handleQuizSubmissionFeedback(subId, body) {
    const list = this.readJsonFile("submissions.json", []);
    const item = list.find((s) => s.submission_id === subId || s.question_id === subId);
    if (!item) throw new Error(`Submission not found: ${subId}`);

    item.status = "completed";
    item.feedback = {
      mastery_level: body.mastery_level || "applied",
      assessment: body.assessment || body.feedback || "",
      what_was_correct: body.what_was_correct || "",
      missing_elements: body.missing_elements || "",
      identified_misconceptions: body.identified_misconceptions || "",
      corrective_lesson: body.corrective_lesson || "",
      follow_up_probe: body.follow_up_probe || "",
      evaluated_at: new Date().toISOString(),
    };
    this.writeJsonFile("submissions.json", list);

    // Update mastery ledger
    if (item.concept_id && item.objective_id) {
      const mastery = this.readJsonFile("mastery.json", {});
      if (!mastery[item.concept_id]) mastery[item.concept_id] = {};
      mastery[item.concept_id][item.objective_id] = {
        level: body.mastery_level || "applied",
        last_updated: new Date().toISOString(),
      };
      this.writeJsonFile("mastery.json", mastery);
    }

    new Notice(`[Evaluation Completed] ${item.question_id}: ${body.mastery_level || "Recorded"}`);
    return { success: true, submission_id: subId, item };
  }

  handleActionSubmissionPost(body) {
    const list = this.readJsonFile("action_requests.json", []);
    const entry = {
      action_id: body.action_id || `act_${Date.now()}`,
      note_path: body.note_path || "",
      section: body.section || "",
      question: body.question || "",
      status: "pending",
      submitted_at: new Date().toISOString(),
    };
    list.push(entry);
    this.writeJsonFile("action_requests.json", list);
    return { success: true, action_id: entry.action_id };
  }

  handleActionSubmissionList(params) {
    const list = this.readJsonFile("action_requests.json", []);
    return { success: true, actions: list };
  }

  handleMasteryGet(params) {
    const mastery = this.readJsonFile("mastery.json", {});
    const concept = params.get("concept_id");
    if (concept) return { success: true, concept_id: concept, objectives: mastery[concept] || {} };
    return { success: true, mastery };
  }

  handleMasteryPost(body) {
    const mastery = this.readJsonFile("mastery.json", {});
    const conceptId = body.concept_id;
    if (!conceptId) throw new Error("Missing concept_id");
    mastery[conceptId] = { ...mastery[conceptId], ...body.objectives };
    this.writeJsonFile("mastery.json", mastery);
    return { success: true, concept_id: conceptId, objectives: mastery[conceptId] };
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
