/**
 * DuckDB Evidence Ledger Client
 */

import { execSync } from "node:child_process";
import os from "node:os";
import path from "node:path";
import fs from "node:fs";

const DEFAULT_DB_PATH = path.join(
  process.env.XDG_DATA_HOME || path.join(os.homedir(), ".local/share"),
  "nixpi/evidence/ledger.duckdb"
);

export function executeDuckDb(sql, dbPath = DEFAULT_DB_PATH) {
  const dir = path.dirname(dbPath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }

  // Escape single quotes safely for duckdb -json
  const escapedSql = sql.replace(/'/g, "'\\''");
  try {
    const stdout = execSync(`duckdb "${dbPath}" -json -c '${escapedSql}'`, {
      encoding: "utf-8",
      maxBuffer: 10 * 1024 * 1024,
    });
    const parsed = stdout.trim() ? JSON.parse(stdout.trim()) : [];
    return { status: "ok", rows: parsed, rowCount: parsed.length };
  } catch (err) {
    return { status: "error", message: err.message, stderr: err.stderr?.toString() };
  }
}

export function getValidatedOpportunities(dbPath = DEFAULT_DB_PATH) {
  const sql = "SELECT * FROM validated_opportunities_view ORDER BY total_score DESC;";
  return executeDuckDb(sql, dbPath);
}
