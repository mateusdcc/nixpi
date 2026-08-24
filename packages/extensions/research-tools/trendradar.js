/**
 * TrendRadar RSS and Legal Keyword Collector for Pi
 */

export const LEGAL_KEYWORD_GROUPS = {
  workflows: [
    "lawyer workflow",
    "law firm management",
    "legal operations",
    "paralegal workflow",
    "client intake",
    "billing and collections",
    "time tracking",
    "document automation",
    "contract review",
    "deadlines and docketing",
    "court filing",
    "legal research",
    "case management",
    "evidence organization",
    "client communication",
    "compliance",
    "legal AI",
  ],
  brazilian_systems: [
    "PJe",
    "e-SAJ",
    "Projudi",
    "DJe",
    "OAB",
    "CNJ",
  ],
};

export const RSS_FEEDS = {
  global: [
    { name: "Legaltech News", url: "https://www.law.com/legaltechnews/rss/" },
    { name: "LawSites", url: "https://www.lawnext.com/feed" },
    { name: "Artificial Lawyer", url: "https://www.artificiallawyer.com/feed/" },
    { name: "Legal Dive", url: "https://www.legaldive.com/feeds/news/" },
    { name: "ABA Journal", url: "https://www.abajournal.com/feed/" },
    { name: "Legal IT Insider", url: "https://legaltechnology.com/feed/" },
    { name: "3 Geeks and a Law Blog", url: "https://www.geeklawblog.com/feed" },
  ],
  brazil: [
    { name: "Consultor Juridico (ConJur)", url: "https://www.conjur.com.br/rss.xml" },
    { name: "JOTA", url: "https://www.jota.info/feed" },
    { name: "Migalhas", url: "https://www.migalhas.com.br/rss" },
    { name: "AB2L", url: "https://ab2l.org.br/feed/" },
    { name: "CNJ Noticias", url: "https://www.cnj.jus.br/feed/" },
  ],
};

export async function fetchRssFeed(feedUrl) {
  try {
    const res = await fetch(feedUrl, { headers: { "User-Agent": "NixPi-Research/1.0" } });
    if (!res.ok) {
      return { status: "error", message: `HTTP ${res.status}: ${res.statusText}` };
    }
    const text = await res.text();
    return { status: "ok", url: feedUrl, rawLength: text.length, contentSnippet: text.slice(0, 2000) };
  } catch (err) {
    return { status: "error", message: err.message };
  }
}
