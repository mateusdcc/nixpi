{
  pkgs,
  mkPiSkill ? (pkgs.callPackage ../../../lib/mk-resource.nix { }).mkPiSkill,
}:

mkPiSkill {
  name = "legal-market-segmentation";
  description = "Segments practitioners by firm size, role, practice area, and jurisdiction.";
  content = ''
    # Legal Market Segmentation Protocol

    ## Objective
    Classify discovered pain points and software products into precise practitioner segments, practice areas, and jurisdictions.

    ## Taxonomy

    ### 1. Firm Size & Organization Structure
    - **Solo Practitioners (1)**: Budget-conscious, needs self-serve zero-onboarding software, handles both lawyering and billing.
    - **Small Firms (2-10)**: 1-2 managing partners, 1 paralegal/secretary, needs multi-user coordination without enterprise IT complexity.
    - **Mid & Large Firms (11+)**: Departmental silos, IT security review required, custom billing guidelines (LEDES/UTBMS), complex permissions.
    - **In-House Legal Teams**: Focus on outside counsel management, vendor cost control, contract turn-around time, executive reporting.
    - **Legal Operations**: Focus on automation, tooling integrations, process velocity, metric dashboards.
    - **Paralegals & Legal Admins**: Heavy execution layer for court filings, document formatting, exhibits, scheduling, client check-ins.

    ### 2. Practice Area Nuances
    - **Labor & Employment (Trabalhista)**: Massive volume, tight calculation requirements (horas extras, verbas rescisórias), high hearing frequency.
    - **Civil Litigation (Cível/Consumidor)**: High volume mass litigation, court portal tracking (PJe/e-SAJ), standardized petitions.
    - **Corporate & M&A (Societário/Contratos)**: Complex bespoke drafting, version control, multijurisdictional closing checklists.
    - **Tax (Tributário)**: Calculation complexity, administrative tribunal tracking (CARF/TIT), regulatory volatility.
    - **Family & Probate (Família/Sucessões)**: Emotional client communication, asset division calculations, high document volume.
    - **Criminal (Penal)**: Urgent deadlines, custody hearings, prison communication, privacy constraints.

    ### 3. Jurisdiction Separation
    - **Foreign Jurisdictions (US, UK, CA, AU, EU)**: Common law vs. Civil law differences, billing by the 6-minute increment, US state court variation.
    - **Brazil (BR)**: Unified federal/state court electronic filing systems (PJe, e-SAJ, Projudi, Eproc), OAB regulations, Pix payments, WhatsApp dominance.
  '';
}
