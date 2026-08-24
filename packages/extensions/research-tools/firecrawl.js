/**
 * Firecrawl MCP Page Extraction Client
 */

export async function scrapeFirecrawl(url, options = {}) {
  const apiKey = process.env.FIRECRAWL_API_KEY;
  if (!apiKey) {
    return {
      status: "pending",
      message: "FIRECRAWL_API_KEY is not set. Please export FIRECRAWL_API_KEY to enable Firecrawl extraction.",
    };
  }

  const payload = {
    url,
    formats: options.formats || ["markdown", "html"],
    onlyMainContent: options.onlyMainContent !== false,
  };

  try {
    const res = await fetch("https://api.firecrawl.dev/v1/scrape", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${apiKey}`,
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

export async function crawlFirecrawl(url, options = {}) {
  const apiKey = process.env.FIRECRAWL_API_KEY;
  if (!apiKey) {
    return { status: "pending", message: "FIRECRAWL_API_KEY is not set." };
  }

  try {
    const res = await fetch("https://api.firecrawl.dev/v1/crawl", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${apiKey}`,
      },
      body: JSON.stringify({ url, limit: options.limit || 10 }),
    });
    if (!res.ok) {
      return { status: "error", code: res.status, message: res.statusText };
    }
    return await res.json();
  } catch (err) {
    return { status: "error", message: err.message };
  }
}
