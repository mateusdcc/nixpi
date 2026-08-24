/**
 * Chrome MCP Isolated Profile Browser Client
 */

import { execSync } from "node:child_process";
import os from "node:os";
import path from "node:path";
import fs from "node:fs";

const CHROME_PROFILE_DIR = path.join(
  process.env.XDG_DATA_HOME || path.join(os.homedir(), ".local/share"),
  "nixpi/chrome-research-profile"
);

export function getChromeProfileDir() {
  if (!fs.existsSync(CHROME_PROFILE_DIR)) {
    fs.mkdirSync(CHROME_PROFILE_DIR, { recursive: true });
  }
  return CHROME_PROFILE_DIR;
}

export function fetchPageIsolatedChrome(url) {
  const profileDir = getChromeProfileDir();
  // Ensure read-only headless extraction with isolated profile
  const chromeBinary = process.env.CHROME_BIN || "google-chrome-stable" || "chromium" || "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
  const cmd = `"${chromeBinary}" --headless --disable-gpu --user-data-dir="${profileDir}" --dump-dom "${url}"`;

  try {
    const html = execSync(cmd, { encoding: "utf-8", timeout: 20000 });
    return {
      status: "ok",
      url,
      profileDir,
      mode: "read-only-isolated",
      htmlSnippet: html.slice(0, 5000),
      fullLength: html.length,
    };
  } catch (err) {
    return {
      status: "error",
      message: `Chrome isolated extraction failed: ${err.message}`,
      fallback: "Use Firecrawl or Exa for content extraction.",
    };
  }
}
