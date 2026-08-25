{
  pkgs,
  mkPiSkill ? (pkgs.callPackage ../../../lib/mk-resource.nix { }).mkPiSkill,
}:

mkPiSkill {
  name = "mermaid-diagrams";
  description = "High-precision Mermaid diagram architecture and isolated subagent validation for complex conceptual workflows.";
  runtimePackages = [
    pkgs.mermaid-cli
  ];
  content = ''
    # Mermaid Diagram Generation & Subagent Validation Protocol

    ## Objective
    Produce pixel-perfect, syntactically valid Mermaid diagrams for conceptual notes and architecture guides while keeping the main conversation context token-efficient.

    ## Subagent Isolation Strategy
    To avoid token bloat and context window pollution in the main agent:
    1. **Delegate Diagram Construction**:
       - When creating or refining complex diagrams, delegate the generation to a specialized lightweight subagent (or isolated tool prompt) whose ONLY role is constructing and syntax-checking the Mermaid code.
       - The subagent focuses strictly on visual graph topology and syntax validity without carrying conversational history.
    2. **Syntax Validation**:
       - Verify syntax with `mmdc` (Mermaid CLI):
         ```bash
         echo '<mermaid-code>' | mmdc -i - -o /dev/null
         ```
       - Ensure all node labels containing special characters (parentheses, brackets, colons) are strictly quoted: e.g. `id["Label (Extra Info)"]`.
    3. **Return Clean Block**:
       - Return only the final verified ```mermaid ... ``` markdown block to be inserted into the note.

    ## Supported Diagram Types
    - **Concept Map & Flow**: `flowchart TD` or `flowchart LR` with styled subgraphs.
    - **State Transitions**: `stateDiagram-v2` with clear transitions, composite states, and guards.
    - **Protocol Flow**: `sequenceDiagram` with notes, activation boxes, and parallel blocks (`par`).
    - **Domain Entities**: `classDiagram` or `erDiagram` showing cardinality and types.
    - **Cognitive Tree**: `mindmap` for hierarchical idea decomposition.
  '';
}
