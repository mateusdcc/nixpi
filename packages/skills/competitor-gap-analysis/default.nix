{
  pkgs,
  mkPiSkill ? (pkgs.callPackage ../../../lib/mk-resource.nix { }).mkPiSkill,
}:

mkPiSkill {
  name = "competitor-gap-analysis";
  description = "Maps existing legal tools, pricing, missing features, and switching reasons.";
  content = ''
    # Competitor Gap Analysis Protocol

    ## Objective
    Analyze existing software solutions in the target workflow to identify feature gaps, implementation failures, pricing mismatches, and structural moats.

    ## Analysis Matrix
    1. **Incumbent Mapping**: Identify market leaders in US/Global (e.g. Clio, MyCase, Smokeball, Ironclad, CaseText) and Brazil (e.g. Projuris, Astrea, Lawsoft, ADVbox, Kurier, Espaider).
    2. **Pricing & Packaging**: Per-user/mo vs. flat tier, setup/onboarding fees, contract lock-ins, addon charges for SMS/e-signature.
    3. **Common Practitioner Complaints**:
       - Bloated interface with 80% unused features
       - Lack of native WhatsApp or mobile notifications
       - Clunky court portal synchronization
       - Slow customer support / difficult migration
       - Poor document automation formatting
    4. **Switching Triggers**: What makes a firm actually abandon their current tool?
       - Price increases (> 30%)
       - Missed deadline or court filing failure due to sync lag
       - Need for modern client experience (mobile/WhatsApp portal)
    5. **Moat vs. UX Vulnerability**:
       - *Structurally Protected*: Hard data lock-in with custom on-premise servers or proprietary court access agreements.
       - *Weak UX Vulnerability*: Incumbent has modern APIs or web interface but clunky user workflows and slow development cycles.
  '';
}
