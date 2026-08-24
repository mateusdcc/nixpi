{
  pkgs,
  mkPiSkill ? (pkgs.callPackage ../../../lib/mk-resource.nix { }).mkPiSkill,
}:

mkPiSkill {
  name = "product-opportunity-report";
  description = "Produces structured, ranked product opportunity reports with evidence and Brazil MVP scope.";
  content = ''
    # Legal Tech Product Opportunity Report Template

    ## Objective
    Generate a standardized, ranked dossier for validated legal software opportunities, synthesizing empirical Voice of Customer evidence, market gap analysis, and Brazilian localization feasibility.

    ## Required Report Structure for Each Opportunity

    ### 1. Header & Summary
    - **Opportunity Title**: Clear, descriptive product concept name.
    - **Opportunity Score**: [0 - 100] (with score breakdown).
    - **Confidence Level**: High / Medium / Low.
    - **Target Practitioner Segment**: Solo / Small Firm / Mid-Large / In-House / Legal Ops / Paralegal.
    - **Job to Be Done (JTBD)**: "When [situation], I want to [motivation], so I can [expected outcome]."

    ### 2. The Empirical Pain
    - **Recurring Pain Description**: Specific operational breakdown.
    - **Frequency & Severity**: Daily/Weekly/Monthly; Annoyance/Operational Drag/Financial Loss/Malpractice Risk.
    - **Supporting Verbatim Quotes**: Minimum 5 attributable quotes with source links and publication dates.
    - **Countries & Languages**: Discovered jurisdictions (US, UK, BR, etc.).
    - **Current Workaround**: Excel spreadsheets, physical folders, manual rekeying, WhatsApp audio messages.

    ### 3. Incumbents & Market Gap
    - **Existing Products**: Tools currently serving this space (Global & Brazilian).
    - **Why Existing Products Fail**: Over-complex UI, missing WhatsApp integration, inflexible workflow, poor court sync, predatory pricing.
    - **Willingness-to-Pay Evidence**: Documented spend, Upwork budget, SaaS subscription cost, billable hour leakage.

    ### 4. Brazil Localization Strategy
    - **Brazilian Market Equivalent**: Localized concept name and workflow fit (e.g. *Gestão de Prazos PJe/e-SAJ com Automação WhatsApp*).
    - **Structural Moats**: PJe/e-SAJ/Projudi integrations, Certificado Digital ICP-Brasil, Pix & Boleto billing, LGPD compliance, OAB ethical advertising compliance.
    - **Go-To-Market & Distribution Channels**: OAB subseções, legal influencer partnerships, WhatsApp legal communities, direct outbound to managing partners.

    ### 5. Risk Assessment & Rejection Reasons
    - **Collaboration Dependencies**: Reluctant court clerks, vendor API blocks.
    - **Regulatory & Data Risks**: Court scraping bans, CAPTCHA hurdles, LGPD exposure.
    - **General AI Vulnerability**: Why raw ChatGPT/Claude is not a sufficient solution.
    - **Potential Reasons to Reject**: Key conditions that would invalidate the business.

    ### 6. Execution Plan
    - **30-Day MVP Scope**: Core minimal feature set deliverable in 4 weeks.
    - **Validation Experiment**: 7-day landing page / concierge test to pre-sell or collect 10 LOIs from Brazilian lawyers.
  '';
}
