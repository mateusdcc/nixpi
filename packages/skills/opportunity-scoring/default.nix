{
  pkgs,
  mkPiSkill ? (pkgs.callPackage ../../../lib/mk-resource.nix { }).mkPiSkill,
}:

mkPiSkill {
  name = "opportunity-scoring";
  description = "Scores legal software opportunities (0-100) using positive criteria and strict risk penalties.";
  content = ''
    # Legal Product Opportunity Scoring Model (0 - 100 Points)

    ## Objective
    Provide an objective, evidence-driven score for candidate product opportunities, balancing market demand signals against localization, technical, and regulatory risks.

    ## Positive Scoring Criteria (Max 100 Points)

    1. **Pain Recurrence (0 - 15 pts)**
       - 15: Daily recurring friction across every active matter.
       - 10: Weekly or per-filing recurrence.
       - 5: Occasional or monthly friction.
       - 0: Rare / one-off incident.

    2. **Severity & Consequence (0 - 15 pts)**
       - 15: Missed court deadline, legal malpractice liability, or immediate revenue loss.
       - 10: Significant operational delay or multi-hour administrative bottleneck.
       - 5: Minor inconvenience or cosmetic annoyance.
       - 0: Negligible impact.

    3. **Measurable Time or Financial Cost (0 - 15 pts)**
       - 15: Documented > 5 hours/week per lawyer or > $1,000/month financial leakage.
       - 10: Documented 2-4 hours/week per lawyer.
       - 5: Vague or non-quantified time loss.
       - 0: No measurable loss identified.

    4. **Evidence of Current Spending or Willingness to Pay (0 - 15 pts)**
       - 15: Verbatim quotes stating active budget / willingness to pay, or active Upwork job posts.
       - 10: Clear spend on existing inadequate alternative software.
       - 5: Implied budget from firm size and hourly rate.
       - 0: Expectation that tool should be free.

    5. **Dissatisfaction with Existing Solutions (0 - 10 pts)**
       - 10: High churn, active negative reviews (1-2 stars), complaints of legacy abandonment.
       - 6: Moderately disliked tools with few alternatives.
       - 2: Incumbents are mediocre but tolerated.
       - 0: Incumbent solutions are widely loved.

    6. **Reachable Target Customer (0 - 10 pts)**
       - 10: Highly concentrated, reachable via OAB subgroups, LinkedIn, or legal associations.
       - 6: Standard B2B sales cycle with identifiable managing partners.
       - 2: Fragmented or elusive decision makers.
       - 0: Unreachable enterprise procurement committee.

    7. **Brazilian Localization Advantage (0 - 10 pts)**
       - 10: Heavy structural localization needed (PJe/e-SAJ, CPC, Pix, WhatsApp) creating a strong local moat against US entrants.
       - 6: Moderate Portuguese translation and local billing required.
       - 2: Minimal localization advantage (foreign tools work as-is).
       - 0: No Brazilian applicability.

    8. **MVP Deliverable within 30 Days (0 - 10 pts)**
       - 10: Clear scoped software MVP achievable by 1-2 engineers in 30 days without complex hardware or massive training datasets.
       - 6: Feasible within 60 days.
       - 2: Requires 3-6 months.
       - 0: Requires multi-year R&D or extensive enterprise integrations.

    ## Penalty Deductions (Negative Modifiers)

    - **Restricted Data & Fragile Scraping (Up to -30 pts)**: Heavy reliance on fragile CAPTCHA-bypassing scrapers, unpublished court APIs, or pending regulatory approvals.
    - **Hostile Collaboration Dependency (Up to -20 pts)**: Reliance on reluctant court clerks, adversarial opposing counsel, or unresponsive enterprise vendors.
    - **Network Effects / Marketplace Cold-Start (Up to -20 pts)**: Product only provides value if opposing parties or millions of users are already active.
    - **General AI Adequacy (Up to -15 pts)**: ChatGPT, Claude, or basic LLM prompt wrappers already solve 90% of the problem out of the box.
    - **Weak / Biased Evidence (Up to -15 pts)**: Signals derived solely from vendor blogs, duplicate Reddit threads, or unverified claims.

    ## Opportunity Thresholds
    - **>= 75 Points**: **Strong Validated Opportunity** (High priority for 30-day MVP).
    - **60 - 74 Points**: **Conditional Opportunity** (Requires deeper Brazilian validation).
    - **< 60 Points**: **Reject / Backlog** (Document in `rejected_opportunities` table).
  '';
}
