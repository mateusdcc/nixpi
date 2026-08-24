/**
 * Exa MCP Search Client
 */

export async function searchExa(query, options = {}) {
  const apiKey = process.env.EXA_API_KEY;
  if (!apiKey) {
    return {
      status: "pending",
      message: "EXA_API_KEY is not set. Please export EXA_API_KEY to enable Exa semantic search.",
    };
  }

  const payload = {
    query,
    numResults: options.numResults || 10,
    includeDomains: options.includeDomains,
    excludeDomains: options.excludeDomains,
    category: options.category || "company",
    contents: {
      text: true,
      highlights: true,
      summary: true,
    },
  };

  try {
    const res = await fetch("https://api.exa.ai/search", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": apiKey,
      },
      body: JSON.stringify(payload),
    });
    if (!res.ok) {
      return { status: "error", code: res.status, message: res.statusText };
    }
    return await res.json();
  } catch (err) {
    return { status: "error", message: err.message };
  }
}
