{
  pkgs,
  mkPiSkill ? (pkgs.callPackage ../../../lib/mk-resource.nix { }).mkPiSkill,
}:

mkPiSkill {
  name = "evidence-deduplication";
  description = "Detects reposts, syndicated reviews, PR content, and duplicates across evidence records.";
  content = ''
    # Evidence Deduplication Protocol

    ## Objective
    Ensure evidence integrity by identifying and clustering duplicate, syndicated, or derivative content so that a single event or vendor campaign is not counted as multiple independent user signals.

    ## Deduplication Rules
    1. **Syndicated Reviews**: G2, Capterra, and Trustpilot reviews sometimes syndicate across Gartner sites. If text, author, and date match within 48 hours, cluster under a single `duplicate_group_id`.
    2. **News Syndication & PR**: A single press release republished by multiple legal tech blogs counts as **1 source event**, not multiple market demand signals.
    3. **Vendor Content**: Whitepapers, sponsored posts, and vendor blog posts advocating for their own category must be flagged as vendor-originated (`reliability_score: 0.3`) and cannot serve as primary Voice of Customer evidence.
    4. **Forum Cross-Posting**: The same user posting to r/lawyers and r/legalops within a week represents **1 user**, not 2.
    5. **Aggregation Multipliers**: Reddit upvotes and YouTube comment counts indicate resonance, but a thread with 100 upvotes and 1 author still counts as **1 primary quotation** plus an engagement signal.

    ## Verification in DuckDB
    - Assign each raw evidence entry a `duplicate_group_id` matching its canonical cluster.
    - When counting independent users in `validated_opportunities_view`, group by `author_anonymized_id` and distinct `source_type`.
  '';
}
