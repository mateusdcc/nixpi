{
  pkgs,
  mkPiSkill ? (pkgs.callPackage ../../../lib/mk-resource.nix { }).mkPiSkill,
}:

mkPiSkill {
  name = "legal-pain-discovery";
  description = "Orchestrates research on lawyer, paralegal, and legal-ops workflow pains across jurisdictions.";
  content = ''
    # Legal Pain Discovery Protocol

    ## Objective
    Discover recurring, high-friction operational pain points experienced by legal practitioners (lawyers, paralegals, legal ops, firm managers) across foreign jurisdictions (US, UK, CA, AU, EU) and Brazil.

    ## Critical Invariant
    **NEVER mix client complaints with practitioner operational pains.**
    - EXCLUDE: "My lawyer took too long to call me back" or "Legal fees are too high for consumers".
    - INCLUDE: "Our firm wastes 6 hours a week manually rekeying billing entries across two practice management tools" or "PJe deadline reconciliation requires 3 different spreadsheets".

    ## Discovery Matrix

    ### 1. Practitioner Segments
    - Solo Practitioners (generalist, resource-constrained, high administrative overhead)
    - Small Firms (2-10 lawyers, ad-hoc workflows, cash-flow sensitive)
    - Mid to Large Law Firms (10+ lawyers, departmentalized, IT/security constraints)
    - In-House Legal Departments (risk management, vendor/contract control, budget tracking)
    - Legal Operations (process optimization, tech adoption, analytics)
    - Paralegals and Legal Administrative Staff (docketing, filing, document drafting, scheduling)

    ### 2. Practice Areas
    - Litigation (civil, labor, commercial, criminal, tax)
    - Transactional & Corporate (M&A, contract lifecycle, compliance)
    - Specialized (Family, Real Estate, Labor & Employment, Tax, IP)

    ### 3. Core Workflows
    1. Client Intake & Onboarding
    2. Billing, Invoicing & Collections
    3. Time Tracking & Fee Capture
    4. Document Automation & Assembly
    5. Contract Review & Redlining
    6. Deadlines, Calendaring & Docketing
    7. Court Filing & Electronic Submissions
    8. Legal Research & Jurisprudence
    9. Case & Matter Management
    10. Evidence Organization & Exhibit Management
    11. Client Communication & Status Updates
    12. Compliance & Regulatory Monitoring

    ## Research Execution Steps
    1. Query TrendRadar and BigIdeasDB for emerging themes and pre-clustered complaint clusters.
    2. Run Exa semantic search targeting niche legal software discussions, practitioner blogs, and specialized legal-tech roundups.
    3. Scrape community discussions using Apify (Reddit r/lawyers, r/paralegal, r/legalops, Capterra, G2, Trustpilot).
    4. Ingest YouTube transcripts of lawyer workflow tutorials, pain teardowns, and tech reviews.
    5. Log all findings into DuckDB raw_evidence table.
  '';
}
