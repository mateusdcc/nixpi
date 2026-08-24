/**
 * World Monitor MCP Client (Conditional)
 * Macroeconomic, regulatory, and geopolitical context only.
 */

export async function queryWorldMonitor(topic, country = "BR") {
  const endpoint = process.env.WORLD_MONITOR_API_URL || "http://127.0.0.1:8080/api/v1/context";
  try {
    const res = await fetch(`${endpoint}?topic=${encodeURIComponent(topic)}&country=${encodeURIComponent(country)}`, {
      headers: { "User-Agent": "NixPi-Research/1.0" },
    });
    if (!res.ok) {
      return {
        status: "disabled_or_unavailable",
        message: `World Monitor at ${endpoint} returned HTTP ${res.status}. Note: World Monitor is conditional and not required for core opportunity discovery.`,
      };
    }
    return await res.json();
  } catch (err) {
    return {
      status: "disabled_or_unavailable",
      message: `World Monitor local endpoint is not running (${err.message}). Macro context remains optional.`,
    };
  }
}
