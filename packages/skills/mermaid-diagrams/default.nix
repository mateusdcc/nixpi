{
  pkgs,
  mkPiSkill ? (pkgs.callPackage ../../../lib/mk-resource.nix { }).mkPiSkill,
}:

mkPiSkill {
  name = "mermaid-diagrams";
  description = "Purpose-driven visual architecture and semantic validation: diagrams are conditional on pedagogical clarity and followed by mandatory tracing questions.";
  runtimePackages = [
    pkgs.mermaid-cli
  ];
  content = ''
    # Purpose-Driven Visual Architecture & Diagram Protocol

    ## Objective
    Provide crisp, semantically meaningful visual models only when they genuinely clarify causal structure or state transitions better than prose or worked traces.

    ## Conditional Diagram Selection Rule
    Select visual representations strictly based on pedagogical purpose:
    - **State Transitions**: `stateDiagram-v2` showing transitions, guards, and terminal states.
    - **Protocol / Message Interactions**: `sequenceDiagram` showing causal message ordering, timeouts, and partitions.
    - **Algorithmic Decisions**: `flowchart TD` showing branch conditions and invariant checks.
    - **Exact Comparisons**: Markdown table (prefer tables over complex diagrams when comparing feature matrices or dimensions).
    - **Temporal / Epoch Shifts**: Timeline or sequential worked trace.
    - **Omit Diagram**: When a small step-by-step mathematical derivation or code execution trace is clearer than a diagram.

    ## Semantic Validation & Tracing Requirement
    1. **Syntax Validation**: Verify syntax with `mmdc` CLI. Ensure all node labels containing special characters are strictly quoted.
    2. **Mandatory Follow-Up Tracing Question**:
       EVERY diagram included in a Concept Lab MUST be immediately followed by an interactive `pi-quiz` question requiring the learner to trace a path, predict a state transition, or analyze a boundary condition on that specific diagram.
  '';
}
