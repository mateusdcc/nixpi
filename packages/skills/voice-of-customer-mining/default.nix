{
  pkgs,
  mkPiSkill ? (pkgs.callPackage ../../../lib/mk-resource.nix { }).mkPiSkill,
}:

mkPiSkill {
  name = "voice-of-customer-mining";
  description = "Extracts verbatim practitioner quotes, affected workflows, severity, and spend signals.";
  content = ''
    # Voice of Customer (VoC) Mining Protocol

    ## Objective
    Extract structured, unembellished Voice of Customer data from legal practitioner discussions, reviews, and community threads. Preserve verbatim quotes and isolate objective operational evidence from speculative commentary.

    ## Required Extraction Fields
    For every candidate evidence snippet, extract:
    1. **Exact Pain Statement**: A concise 1-sentence summary of the operational breakdown.
    2. **Original Quote**: Exact verbatim quotation preserved in the original language (never paraphrased).
    3. **Affected Workflow**: The specific legal workflow impacted (e.g. `deadlines_docketing`, `client_intake`).
    4. **Frequency**: How often the breakdown occurs (`daily`, `weekly`, `per_case`, `monthly`).
    5. **Severity**: Operational impact (`annoyance`, `operational_drag`, `financial_loss`, `malpractice_risk`).
    6. **Time or Money Lost**: Quantifiable loss metrics (e.g. "2 hours/day", "$500/month in missed billables", "paralegal overtime").
    7. **Current Workaround**: What the practitioner does today (e.g. "manual Excel tracker", "color-coded sticky notes", "WhatsApp voice notes").
    8. **Software Currently Used**: Products mentioned (e.g. Clio, MyCase, Projuris, Astrea, Lawsoft, Excel).
    9. **Desired Result**: What the user explicitly wishes the tool would do.
    10. **Willingness-to-Pay Signal**: Explicit budget, active spending, or statement of buying intent (e.g. "I would pay $100/mo for a tool that just does this").

    ## Mining Guidelines
    - Do not invent metrics if not stated by the user. Mark unstated metrics as `null`.
    - Distinguish between a feature request for an existing behemoth and an independent product opportunity.
    - Always record source URL, publication date, country, and anonymized author handle.
    - Persist each extracted instance to DuckDB `raw_evidence` and `spend_signals` tables.
  '';
}
