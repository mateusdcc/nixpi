/**
 * BigIdeasDB MCP Client & Diagnostic Handler
 */

export async function queryBigIdeasDb(endpoint, params = {}) {
  const apiKey = process.env.BIGIDEASDB_API_KEY;
  if (!apiKey) {
    return {
      status: "pending",
      message: "BIGIDEASDB_API_KEY is not set. BigIdeasDB integration is in pending state. Research stack continues without it.",
      suggestedNextStep: "Provide BIGIDEASDB_API_KEY via environment variable or auth config when available.",
      fallback: "Using Exa, Firecrawl, and Apify as primary discovery and review sources.",
    };
  }

  const url = `https://api.bigideasdb.com/v1/${endpoint}`;
  try {
    const res = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${apiKey}`,
      },
      body: JSON.stringify(params),
    });
    if (!res.ok) {
      return { status: "error", code: res.status, message: res.statusText };
    }
    return await res.json();
  } catch (err) {
    return { status: "error", message: err.message };
  }
}
