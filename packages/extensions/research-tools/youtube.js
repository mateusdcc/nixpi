/**
 * YouTube Transcript Tool Bridge
 */

import { execSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import path from "node:path";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const SCRIPT_PATH = path.join(__dirname, "get-transcript.py");

export function getYouTubeTranscript(videoUrlOrId, languages = "en,pt,es") {
  try {
    const output = execSync(`python3 "${SCRIPT_PATH}" "${videoUrlOrId}" "${languages}"`, {
      encoding: "utf-8",
      timeout: 30000,
    });
    return JSON.parse(output.trim());
  } catch (err) {
    return { status: "error", message: err.message, stderr: err.stderr?.toString() };
  }
}
