import { findVaultPath } from "./vault.js";
import {
  openNoteInApp,
  splitObsidianScreen,
  listObsidianCommands,
  runObsidianCommand,
  openObsidianSettings,
  getObsidianLayout,
  takeObsidianScreenshot,
  promptObsidianModal,
  showObsidianNotice,
  getQuizSubmissions,
  evaluateQuizSubmission,
  getActionSubmissions,
  getMasteryLedger,
  updateMasteryLedger,
  migrateNoteSections,
  appendSectionAddition,
  getLearningSession,
  updateLearningSession,
  branchToPrerequisite,
  returnFromPrerequisiteBranch,
  recordMasteryEvidence,
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

  pi.registerTool({
    name: "obsidian_prompt_modal",
    label: "Obsidian Prompt Modal",
    description: "Open an interactive quiz or knowledge probe modal directly inside Obsidian and await user responses",
    parameters: {
      type: "object",
      properties: {
        title: { type: "string", description: "Modal title heading" },
        description: { type: "string", description: "Modal instructions" },
        submitText: { type: "string", description: "Button submit text" },
        questions: {
          type: "array",
          description: "List of questions (easy, medium, hard)",
          items: {
            type: "object",
            properties: {
              id: { type: "string" },
              tier: { type: "string", enum: ["easy", "medium", "hard"] },
              type: { type: "string", enum: ["choice", "open"] },
              question: { type: "string" },
              options: { type: "array", items: { type: "string" } },
              placeholder: { type: "string" },
              rows: { type: "integer" },
            },
            required: ["question"],
          },
        },
      },
      required: ["title", "questions"],
    },
    async execute(id, params) {
      const res = await promptObsidianModal(params);
      return respond(res);
    },
  });

  pi.registerTool({
    name: "obsidian_show_notice",
    label: "Obsidian Show Notice",
    description: "Display a non-intrusive popup notice toast in the top right corner of Obsidian",
    parameters: {
      type: "object",
      properties: {
        message: { type: "string", description: "Notice text" },
        duration: { type: "integer", default: 5000, description: "Duration in milliseconds" },
      },
      required: ["message"],
    },
    async execute(id, params) {
      const res = await showObsidianNotice(params?.message, params?.duration || 5000);
      return respond(res);
    },
  });

  pi.registerTool({
    name: "obsidian_get_quiz_submissions",
    label: "Obsidian Get Quiz Submissions",
    description: "Retrieve quiz answers and user submissions from the learning queue for Pi evaluation",
    parameters: {
      type: "object",
      properties: {
        status: { type: "string", enum: ["pending", "completed"], description: "Optional status filter" },
        concept_id: { type: "string", description: "Optional concept ID filter" },
      },
    },
    async execute(id, params) {
      const res = await getQuizSubmissions(params || {});
      return respond(res);
    },
  });

  pi.registerTool({
    name: "obsidian_evaluate_quiz_submission",
    label: "Obsidian Evaluate Quiz Submission",
    description: "Evaluate a learner's quiz submission against rubrics, providing inline feedback and updating the objective mastery ledger",
    parameters: {
      type: "object",
      properties: {
        submission_id: { type: "string", description: "Submission ID or question ID" },
        mastery_level: {
          type: "string",
          enum: ["unprobed", "recognized", "explained", "applied", "transferred", "critiqued_constructed"],
          description: "Assessed mastery level for this objective",
        },
        assessment: { type: "string", description: "Concise overall evaluation summary" },
        what_was_correct: { type: "string", description: "What reasoning was sound" },
        missing_elements: { type: "string", description: "What was missing or imprecise" },
        identified_misconceptions: { type: "string", description: "Identified misconception if present" },
        corrective_lesson: { type: "string", description: "Targeted corrective explanation" },
        follow_up_probe: { type: "string", description: "New isomorphic retry question" },
      },
      required: ["submission_id", "mastery_level", "assessment"],
    },
    async execute(id, params) {
      const res = await evaluateQuizSubmission(params.submission_id, params);
      return respond(res);
    },
  });

  pi.registerTool({
    name: "obsidian_get_action_requests",
    label: "Obsidian Get Action Requests",
    description: "Retrieve section inquiries and questions submitted by the learner via in-note pi-action blocks",
    parameters: { type: "object", properties: {} },
    async execute() {
      const res = await getActionSubmissions();
      return respond(res);
    },
  });

  pi.registerTool({
    name: "obsidian_get_mastery_state",
    label: "Obsidian Get Mastery State",
    description: "Retrieve the objective-level mastery ledger across concepts and units",
    parameters: {
      type: "object",
      properties: {
        concept_id: { type: "string", description: "Optional concept ID to inspect" },
      },
    },
    async execute(id, params) {
      const res = await getMasteryLedger(params?.concept_id);
      return respond(res);
    },
  });

  pi.registerTool({
    name: "obsidian_update_mastery_state",
    label: "Obsidian Update Mastery State",
    description: "Update the objective-level mastery ledger for a concept",
    parameters: {
      type: "object",
      properties: {
        concept_id: { type: "string", description: "Concept ID" },
        objectives: { type: "object", description: "Objective status mappings" },
      },
      required: ["concept_id", "objectives"],
    },
    async execute(id, params) {
      const res = await updateMasteryLedger(params.concept_id, params.objectives);
      return respond(res);
    },
  });

  pi.registerTool({
    name: "obsidian_migrate_note_sections",
    label: "Obsidian Migrate Note Sections",
    description: "Migrate an existing Concept Lab note to include protected Layer A core markers and Layer B additions markers without changing any prose",
    parameters: {
      type: "object",
      properties: {
        note_path: { type: "string", description: "Relative or absolute path to the Concept Lab note" },
      },
      required: ["note_path"],
    },
    async execute(id, params) {
      const res = await migrateNoteSections(params.note_path);
      return respond(res);
    },
  });

  pi.registerTool({
    name: "obsidian_append_section_addition",
    label: "Obsidian Append Section Addition",
    description: "Append a curated dialogue-derived learning addition (clarification, concrete model, precision correction, prerequisite link) to the protected additions block of a Concept Lab section",
    parameters: {
      type: "object",
      properties: {
        note_path: { type: "string", description: "Path to the Concept Lab note" },
        section_id: { type: "string", description: "Section slug (e.g. formal-core, intuitive-causal-model)" },
        addition_id: { type: "string", description: "Unique idempotent addition ID" },
        addition_type: {
          type: "string",
          enum: ["clarification", "concrete_model", "analogy", "correction", "prerequisite_branch"],
          description: "Category of addition",
        },
        source_question_id: { type: "string", description: "Question ID that exposed the gap" },
        content: { type: "string", description: "Curated markdown content to append" },
        linked_notes: { type: "array", items: { type: "string" }, description: "Optional list of linked note names" },
      },
      required: ["note_path", "section_id", "addition_id", "content"],
    },
    async execute(id, params) {
      const res = await appendSectionAddition(params);
      return respond(res);
    },
  });

  pi.registerTool({
    name: "obsidian_get_learning_session",
    label: "Obsidian Get Learning Session",
    description: "Retrieve the active learning session state, active section, branch stack, and unresolved concepts",
    parameters: { type: "object", properties: {} },
    async execute() {
      const res = await getLearningSession();
      return respond(res);
    },
  });

  pi.registerTool({
    name: "obsidian_update_learning_session",
    label: "Obsidian Update Learning Session",
    description: "Update the active learning session (active_section_id, active_objective_id, current_state, etc.)",
    parameters: {
      type: "object",
      properties: {
        topic_id: { type: "string" },
        lab_path: { type: "string" },
        lab_status: { type: "string", enum: ["idle", "learning", "mastered"] },
        active_section_id: { type: "string" },
        active_objective_id: { type: "string" },
        current_state: {
          type: "string",
          enum: [
            "LAB_CREATED",
            "SECTION_SELECTED",
            "SECTION_TEACHING",
            "QUESTION_AND_CLARIFICATION_LOOP",
            "PREREQUISITE_BRANCH",
            "PREREQUISITE_TEACHING",
            "PREREQUISITE_MASTERY_GATE",
            "RETURN_TO_PARENT_SECTION",
            "SECTION_NOTE_SYNC",
            "SECTION_MASTERY_GATE",
            "LEARNER_CONFIRMATION",
            "NEXT_SECTION",
          ],
        },
        unresolved_questions: { type: "array", items: { type: "string" } },
        misconceptions: { type: "array", items: { type: "string" } },
      },
    },
    async execute(id, params) {
      const res = await updateLearningSession(params);
      return respond(res);
    },
  });

  pi.registerTool({
    name: "obsidian_branch_prerequisite",
    label: "Obsidian Branch Prerequisite",
    description: "Pause the current section and branch to an independent prerequisite Concept Lab, adding a callout link in the parent lab",
    parameters: {
      type: "object",
      properties: {
        parent_lab: { type: "string", description: "Path to parent Concept Lab" },
        triggered_from_section: { type: "string", description: "Active parent section ID" },
        triggered_by_question: { type: "string", description: "Learner question or probe that exposed the gap" },
        prerequisite_concept_id: { type: "string", description: "Slug for prerequisite concept" },
        prerequisite_title: { type: "string", description: "Human-readable title" },
        capability_target: { type: "string", description: "Prerequisite capability target description" },
      },
      required: ["parent_lab", "triggered_from_section", "prerequisite_concept_id"],
    },
    async execute(id, params) {
      const res = await branchToPrerequisite(params);
      return respond(res);
    },
  });

  pi.registerTool({
    name: "obsidian_return_from_prerequisite_branch",
    label: "Obsidian Return From Prerequisite Branch",
    description: "Complete prerequisite lab and return to the exact parent section",
    parameters: {
      type: "object",
      properties: {
        prerequisite_concept_id: { type: "string" },
      },
      required: ["prerequisite_concept_id"],
    },
    async execute(id, params) {
      const res = await returnFromPrerequisiteBranch(params);
      return respond(res);
    },
  });

  pi.registerTool({
    name: "obsidian_record_mastery_evidence",
    label: "Obsidian Record Mastery Evidence",
    description: "Record rigorous mastery evidence for an objective. Rejects fake mastery if answers contain 'not sure', 'I do not know', or lack causal explanation.",
    parameters: {
      type: "object",
      properties: {
        concept_id: { type: "string", description: "Concept ID" },
        section_id: { type: "string", description: "Section ID" },
        objective_id: { type: "string", description: "Objective ID" },
        previous_level: { type: "number" },
        new_level: { type: "number", description: "Target level: 0 (unprobed), 1 (recognized), 2 (explained), 3 (applied), 4 (transferred), 5 (critiqued_constructed)" },
        evidence: {
          type: "array",
          items: {
            type: "object",
            properties: {
              question_id: { type: "string" },
              answer_excerpt: { type: "string" },
              evaluation: { type: "string" },
              timestamp: { type: "string" },
            },
            required: ["question_id", "answer_excerpt", "evaluation"],
          },
          description: "List of concrete question answers proving mastery",
        },
        unresolved_misconceptions: { type: "array", items: { type: "string" } },
      },
      required: ["concept_id", "objective_id", "new_level", "evidence"],
    },
    async execute(id, params) {
      const res = await recordMasteryEvidence(params);
      return respond(res);
    },
  });
}



