{
  pkgs,
  mkPiSkill ? (pkgs.callPackage ../../../lib/mk-resource.nix { }).mkPiSkill,
}:

mkPiSkill {
  name = "feynman-technique";
  description = "7-step representation ladder protocol: ascends from plain-language intuition through causal traces and analogies to formal rigor without mechanism loss.";
  content = ''
    # Representation Ladder Protocol (Feynman Technique)

    ## Objective
    Demystify complex technical concepts by climbing a structured representation ladder. Simplification must NEVER delete the causal mechanism.

    ## 7-Step Representation Ladder
    1. **Plain Language Explanation**: State what problem is being solved and why without jargon or circular definitions.
    2. **Concrete Scenario**: Ground the concept in a tangible, observable interaction with specific numbers, states, or messages.
    3. **Step-by-Step Causal Trace**: Walk through the explicit sequence of state transitions ($S_0 \to S_1 \to S_2$) showing what causes each shift.
    4. **Formal Specification**: Express the governing invariant mathematically, algorithmically, or via state-machine rules.
    5. **Explicit Analogy Mapping**: When a cross-domain analogy is used, document:
       - Source domain & target domain.
       - Exact elements that map correctly.
    6. **Analogy Breakdown Boundary**:
       - State explicitly what does NOT map.
       - Identify where the analogy breaks down under edge cases or physical constraints.
    7. **Learner Teach-Back / Compression**:
       - Prompt the learner to explain the mechanism, identify the core invariant, and construct one original near-miss.
  '';
}
