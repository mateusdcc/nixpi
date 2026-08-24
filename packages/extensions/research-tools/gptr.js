/**
 * GPT Researcher MCP Synthesis Fallback (Conditional)
 */

export async function runGptResearcherSynthesis(query, reportType = "research_report") {
  const apiKey = process.env.OPENAI_API_KEY || process.env.ANTHROPIC_API_KEY;
  if (!apiKey) {
    return {
      status: "pending",
      message: "API key is not configured for GPT Researcher. GPT Researcher is a fallback synthesis tool; Pi can synthesize findings directly using local evidence.",
    };
  }

  const endpoint = process.env.GPTR_MCP_URL || "http://127.0.0.1:8000/api/report";
  try {
    const res = await fetch(endpoint, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ query, report_type: reportType }),
    });
    if (!res.ok) {
      return { status: "disabled_or_unavailable", message: `GPTR returned HTTP ${res.status}.` };
    }
    return await res.json();
  } catch (err) {
    return {
      status: "disabled_or_unavailable",
      message: `GPT Researcher server is not running (${err.message}). Core research workflow does not require GPTR.`,
    };
  }
}
