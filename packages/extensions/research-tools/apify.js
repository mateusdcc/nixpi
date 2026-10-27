/**
 * Apify MCP Client with Actor Allowlist Enforcement
 */

export const ALLOWED_ACTORS = [
  "apify/reddit-scraper",
  "streamers/youtube-comments-scraper",
  "apidojo/tweet-scraper",
  "clockworks/tiktok-scraper",
  "automation-lab/g2-scraper",
  "zen-studio/capterra-reviews-scraper",
  "automation-lab/trustpilot",
  "johnvc/apple-app-store-reviews-api",
  "thewolves/google-play-reviews-scraper",
  "maximedupre/product-hunt-scraper",
  "gentle_cloud/hacker-news-scraper",
  "neatrat/upwork-job-scraper",
  "curious_coder/linkedin-company-scraper",
  "johnvc/linkedin-jobs-api",
  "blackfalcondata/reclameaqui-scraper",
];

export async function runApifyActor(actorId, input = {}) {
  const token = process.env.APIFY_TOKEN || process.env.APIFY_API_TOKEN;
  if (!token) {
    return {
      status: "pending",
      message: "APIFY_TOKEN is not set. Please export APIFY_TOKEN to run structured Apify scrapers.",
    };
  }

  const cleanActorId = actorId.replace(/^~/, "");
  if (!ALLOWED_ACTORS.includes(cleanActorId)) {
    return {
      status: "error",
      message: `Actor '${cleanActorId}' is not in the approved reputation allowlist. Approved actors: ${ALLOWED_ACTORS.join(", ")}`,
    };
  }

  const [username, actName] = cleanActorId.split("/");
  const url = `https://api.apify.com/v2/acts/${username}~${actName}/runs?token=${token}&waitForFinish=120`;

  try {
    const res = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(input),
    });
    if (!res.ok) {
      return { status: "error", code: res.status, message: res.statusText };
    }
    return await res.json();
  } catch (err) {
    return { status: "error", message: err.message };
  }
}
