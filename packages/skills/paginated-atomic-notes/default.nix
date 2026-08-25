{
  pkgs,
  mkPiSkill ? (pkgs.callPackage ../../../lib/mk-resource.nix { }).mkPiSkill,
}:

mkPiSkill {
  name = "paginated-atomic-notes";
  description = "Protocol for authoring paginated atomic fact notes in Obsidian with interactive in-note quiz buttons and section actions.";
  content = ''
    # Paginated Atomic Fact Notes Protocol (Interactive In-Note UI & Gifted-Level Rigor)

    ## Objective
    Structure knowledge in the Obsidian vault as a sequence of rigorous, interconnected atomic notes. Each note covers exactly one profound atomic concept with dense insights, verified visual diagrams, segmented sections with interactive `pi-action` buttons, and in-note `pi-quiz` blocks with verification submit buttons.

    ## Critical Directives
    1. **NO TERMINAL LESSON DUMPING**:
       - NEVER print full explanations, roadmaps, or educational notes into the terminal chat.
       - ALL lessons must be written directly as `.md` files in the Obsidian vault and opened with `obsidian_open_note`.
    2. **NO EMOJIS**:
       - Do not use emojis anywhere in terminal responses or inside Obsidian notes.
    3. **Interactive In-Note Buttons**:
       - Every note MUST include interactive ````pi-quiz```` blocks with a "Send to Pi for Verification" button.
       - Every major section MUST include an interactive ````pi-action```` block allowing the user to ask questions or deepen that specific section.
    4. **Gifted-Level Cognitive Density**:
       - Zero fluff, generic introductions, or introductory filler.
       - Ground every concept in first-principles mathematics, state machines, physics, or algorithmic invariants.
       - Prioritize intersubject connections (structural parallels to compilers, operating systems, distributed algorithms, category theory, biology).

    ## Note Architecture with Interactive Code Blocks

    Each note MUST follow this structure:

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

    ```pi-action
    label: Ask Pi About Section 1 Mechanics
    section: 1. First-Principles Mechanics
    prompt: Deepen the mathematical/mechanical proof of this invariant
    ```

    ---

    ## 2. Intersubject Connections & Profound Insights
    <!-- Deep structural parallels to other disciplines (e.g. distributed systems <-> biology, algebra <-> type systems). -->

    ```pi-action
    label: Explore Intersubject Parallels
    section: 2. Intersubject Connections
    prompt: Expand on the cross-disciplinary connection and boundary conditions
    ```

    ---

    ## 3. Visual Mental Model
    <!-- Verified Mermaid diagram generated via the mermaid-diagrams subagent/mmdc -->
    ```mermaid
    flowchart TD
       ...
    ```

    ---

    ## 4. In-Note Quizzes & Verification
    <!-- Interactive quiz blocks rendered with native textareas and 'Send to Pi for Verification' buttons -->

    ```pi-quiz
    id: <topic>-01-q1
    title: Challenge 1: Analytical Derivation & Invariant Proof
    question: <Rigorous question requiring mechanical proof or derivation>
    type: open
    rows: 4
    ```

    ```pi-quiz
    id: <topic>-01-q2
    title: Challenge 2: Edge Case & Adversarial Failure Mode
    question: <Complex scenario probing where the abstraction fails under Byzantine conditions>
    type: open
    rows: 4
    ```

    ```pi-quiz
    id: <topic>-01-q3
    title: Challenge 3: Intersubject Synthesis Essay
    question: <Long-form prompt asking to bridge this concept with an adjacent engineering or theoretical domain>
    type: open
    rows: 5
    ```

    ---

    ## Next Steps in Sequence
    - **Continue to Next Concept**: [[<Next Atomic Note>]]
    - **Cross-Domain Rabbit Hole**: [[<Related Deep Topic>]]
    ```

    ## Authoring Rules
    1. **Strict Atomicity**: One note = One atomic concept.
    2. **Bidirectional Navigation**: Every note must explicitly point to its predecessor at the top and successor at the bottom.
    3. **Immediate Obsidian Opening**: After writing the file, immediately call `obsidian_open_note` to display it in the user's workspace.
    4. **Minimal Chat Confirmation**: Output only a brief confirmation link in terminal (e.g. `Created and opened [[<note-title>]] in Obsidian.`).
  '';
}
