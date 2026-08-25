{
  pkgs,
  mkPiSkill ? (pkgs.callPackage ../../../lib/mk-resource.nix { }).mkPiSkill,
}:

mkPiSkill {
  name = "literature-deep-dive";
  description = "Critical literature analysis protocol: claim ledger, empirical falsifiers, competing explanations, and reproducible worked examples.";
  content = ''
    # Critical Literature & Technical Paper Deep-Dive Protocol

    ## Objective
    Perform rigorous, critical deconstruction of technical papers, whitepapers, RFCs, and architecture proposals.

    ## Analytical Framework
    1. **Claim Ledger**:
       - Distinguish clearly between *author assertions* and *mathematically/empirically established results*.
       - Explicitly record all stated and unstated environmental assumptions.
    2. **Evidence & Falsification**:
       - Identify the strongest empirical/theoretical evidence supporting the claim.
       - Document contrary evidence, benchmark caveats, and edge cases where claims break down.
       - Define the exact experimental observation or countermodel that would falsify the claim.
    3. **Competing Explanations & Trade-Offs**:
       - Analyze alternative designs or competing paradigms.
       - Identify why the alternative was rejected and under what changed constraints it becomes superior.
    4. **Reproducible Worked Example**:
       - Construct a concrete, reproducible trace or minimal toy implementation validating the paper's primary algorithm or invariant.
    5. **Transfer Probes**:
       - Formulate 2 transfer questions applying the paper's core invariant to an adjacent domain.
  '';
}
