/**
 * XHS Downloader API Client (Conditional)
 * Restricted to XiaoHongShu / RedNote China market research.
 */

export async function queryXhs(keyword, options = {}) {
  const endpoint = process.env.XHS_API_URL || "http://127.0.0.1:5000/api/search";
  const payload = {
    keyword,
    download_media: false, // Never download media by default
    preserve_watermark: true,
    page: options.page || 1,
  };

  try {
    const res = await fetch(endpoint, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });
    if (!res.ok) {
      return {
        status: "disabled_or_unavailable",
        message: `XHS Downloader local API at ${endpoint} returned HTTP ${res.status}. XHS is conditional for China legal research.`,
      };
    }
    return await res.json();
  } catch (err) {
    return {
      status: "disabled_or_unavailable",
      message: `XHS Downloader local API is not running (${err.message}). Only invoked when researching Chinese legal workflows.`,
    };
  }
}
