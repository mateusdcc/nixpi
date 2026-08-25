{
  pkgs,
  mkPiSkill ? (pkgs.callPackage ../../../lib/mk-resource.nix { }).mkPiSkill,
}:

mkPiSkill {
  name = "paginated-atomic-notes";
  description = "Protocol for authoring paginated atomic fact notes in Obsidian with top/bottom navigation chains and in-note long-form deep quizzes.";
  content = ''
    # Paginated Atomic Fact Notes Protocol (High Rigor / Gifted-Focused)

    ## Objective
    Structure knowledge in the Obsidian vault as a sequence of rigorous, interconnected atomic notes. Each note covers exactly one profound atomic concept with dense insights, verified visual diagrams, and in-note long-form quizzes.

    ## Critical Directives
    1. **NO TERMINAL LESSON DUMPING**:
       - NEVER print full explanations, roadmaps, or educational notes into the terminal chat.
       - The terminal is only for diagnostic interaction and tool status confirmations.
       - ALL lessons must be written directly as `.md` files in the Obsidian vault and opened with `obsidian_open_note`.
    2. **NO EMOJIS**:
       - Do not use emojis anywhere in terminal responses or inside Obsidian notes.
    3. **Gifted-Level Cognitive Density**:
       - Zero fluff, generic introductions, or introductory filler.
       - Ground every concept in first-principles mathematics, state machines, physics, or algorithmic invariants.
       - Prioritize intersubject connections (structural parallels to compilers, operating systems, distributed algorithms, category theory, biology).

    ## 4-Zone Note Architecture

    Each note MUST follow this strict 4-zone structure:

    ```markdown
    ---
    tags: [concept, learning, <domain>]
    status: permanent
    difficulty: hard
    created: YYYY-MM-DD
    ---

    # [[<Previous Atomic Note>]] ← **Topic: Atomic Fact Title** → [[<Next Atomic Note>]]
    *Prerequisites: [[Prerequisite Note A]], [[Prerequisite Note B]] | Up: [[Parent MOC]]*

    ---

    ## 1. First-Principles Mechanics & Core Invariant
    <!-- Dense, high-rigor, no-fluff explanation. Ground in mathematics, mechanical reality, or formal logic. -->

    ## 2. Intersubject Connections & Profound Insights
    <!-- Deep structural parallels to other disciplines (e.g. distributed systems <-> biology, algebra <-> type systems). -->

    ## 3. Visual Mental Model
    <!-- Verified Mermaid diagram generated via the mermaid-diagrams subagent/mmdc -->
    ```mermaid
    flowchart TD
       ...
    ```

    ---

    ## 4. In-Note Quizzes & Long-Form Probing Challenges
    <!-- Embedded directly inside the note for active retrieval and deep cognitive challenge -->
    ### Conceptual Stress Test
    > [!QUESTION] Challenge 1 (Analytical Derivation)
    > <Rigorous multi-step question requiring derivation or proof>

    > [!QUESTION] Challenge 2 (Edge Case & Failure Mode)
    > <Complex scenario probing where the abstraction fails under adversarial conditions>

    > [!QUESTION] Challenge 3 (Intersubject Synthesis Essay)
    > <Long-form prompt asking to bridge this concept with an adjacent domain>

    ---

    ## Next Steps in Sequence
    - **Continue to Next Concept**: [[<Next Atomic Note>]]
    - **Cross-Domain Rabbit Hole**: [[<Related Deep Topic>]]
    ```

    ## Authoring Rules
    1. **Strict Atomicity**: One note = One atomic concept. If a sub-mechanism requires more than 3 paragraphs, split it into the next paginated note in the sequence.
    2. **Bidirectional Navigation**: Every note must explicitly point to its predecessor at the top and successor at the bottom.
    3. **Immediate Obsidian Opening**: After writing the file, immediately call `obsidian_open_note` to display it in the user's workspace.
    4. **Minimal Chat Confirmation**: Output only a brief link confirmation in terminal (e.g. `Created and opened [[<note-title>]] in Obsidian.`).
  '';
}
